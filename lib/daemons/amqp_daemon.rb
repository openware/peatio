# encoding: UTF-8
# frozen_string_literal: true

require File.join(ENV.fetch('RAILS_ROOT'), 'config', 'environment')

raise "bindings must be provided." if ARGV.size == 0

logger = Rails.logger

conn = Bunny.new AMQPConfig.connect
conn.start

ch = conn.create_channel
id = $0.split(':')[2]
prefetch = AMQPConfig.channel(id)[:prefetch] || 0
ch.prefetch(prefetch) if prefetch > 0
logger.info { "Connected to AMQP broker (prefetch: #{prefetch > 0 ? prefetch : 'default'})" }

terminate = proc do
  # logger is forbidden in signal handling, just use puts here
  puts "Terminating threads .."
  ch.work_pool.kill
  puts "Stopped."
end
Signal.trap("INT",  &terminate)
Signal.trap("TERM", &terminate)

workers = []
ARGV.each do |id|
  begin
    worker = AMQPConfig.binding_worker(id)
    queue  = ch.queue *AMQPConfig.binding_queue(id)

    if args = AMQPConfig.binding_exchange(id)
      x = ch.send *args

      case args.first
      when 'direct'
        queue.bind x, routing_key: AMQPConfig.routing_key(id)
      when 'topic'
        AMQPConfig.topics(id).each do |topic|
          queue.bind x, routing_key: topic
        end
      else
        queue.bind x
      end
    end

    clean_start = AMQPConfig.data[:binding][id][:clean_start]
    queue.purge if clean_start

  rescue Mysql2::Error, ActiveRecord::StatementInvalid => e
    if e.cause.is_a?(Mysql2::Error) || e.is_a?(Mysql2::Error::ConnectionError)
      unless Retry.db
        logger.warn { "Killing worker due to db lost connection..." }
        terminate.call
      end
      retry
    end
  end

  # Enable manual acknowledge mode by setting manual_ack: true.
  queue.subscribe manual_ack: true do |delivery_info, metadata, payload|
    logger.info { "Received: #{payload}" }
    begin

      worker.process(JSON.parse(payload))

      # Send confirmation to RabbitMQ that message has been successfully processed.
      # See http://rubybunny.info/articles/queues.html
      ch.ack(delivery_info.delivery_tag)

    rescue StandardError => e
      if e.cause.is_a?(Mysql2::Error) || e.is_a?(Mysql2::Error::ConnectionError)
        unless Retry.db
          logger.warn { "Killing worker due to db lost connection..." }
          # Ask RabbitMQ to deliver message once again later.
          # See http://rubybunny.info/articles/queues.html
          ch.nack(delivery_info.delivery_tag, false, true)
          terminate.call
        end
        retry
      end
      report_exception(e)
      # Ask RabbitMQ to deliver message once again later.
      # See http://rubybunny.info/articles/queues.html
      ch.nack(delivery_info.delivery_tag, false, true)
    end
  end

  workers << worker
end

%w(USR1 USR2).each do |signal|
  Signal.trap(signal) do
    puts "#{signal} received."
    handler = "on_#{signal.downcase}"
    workers.each {|w| w.send handler if w.respond_to?(handler) }
  end
end

ch.work_pool.join
