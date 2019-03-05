require "rabbitmq/http/client"

require_relative 'injectors'

module Bench
  class Matching
    # TODO: Custom config file support.
    def initialize(config_file_path)
      @config = YAML.load_file(Rails.root.join(config_file_path)).deep_symbolize_keys

      # TODO: Use Faraday instead of RabbitMQ::HTTP::Client.
      @rmq_http_client = ::URI::HTTP.build(
        scheme:   :http,
        host:     ENV.fetch('RABBITMQ_HOST', 'localhost'),
        port:     15672,
        userinfo: "#{ENV.fetch('RABBITMQ_USER', 'guest')}:#{ENV.fetch('RABBITMQ_PASSWORD', 'guest')}"
      ).yield_self { |endpoint| RabbitMQ::HTTP::Client.new(endpoint.to_s) }

      @injector = Injectors.initialize_injector(@config[:orders])
      @currencies = Currency.where(id: @config[:currencies].split(',').map(&:squish).reject(&:blank?))
      @errors = []
    end

    def run!
      # TODO: Check if Matching daemon is running before run.
      Kernel.puts "Creating members ..."
      @members = Factories.create_list(:member, @config[:traders])

      Kernel.puts "Depositing funds ..."
      @members.map(&method(:become_billionaire))

      Kernel.puts "Generating orders by injector and saving them in db..."
      @injector.generate!(@members)

      @orders_number = @injector.size

      Kernel.puts "Publishing messages to RabbitMQ..."
      @publish_started_at = Time.now
      publish_messages

      @publish_finished_at = Time.now
      Kernel.puts "Messages are published to RabbitMQ."

      Kernel.puts "Waiting for order processing by matching daemon..."
      wait_for_messages_processing
      @matching_finished_at = Time.now
    end

    def publish_messages
      Array.new(@config[:threads]) do
        Thread.new do
          loop do
            order = @injector.pop
            break unless order
            AMQPQueue.enqueue(:matching, action: 'submit', order: order.to_matching_attributes)
          rescue StandardError => e
            Kernel.puts e
            @errors << e
          end
        end
      end.map(&:join)
    end

    # TODO: Find better solution for getting message number in queue
    # E.g there is rabbitmqctl list_queues.
    def wait_for_messages_processing
      # Wait for RMQ queue status update.
      loop do
        break if queue_info[:messages].zero? &&
          queue_info[:idle_since].present? &&
          Time.parse("#{queue_info[:idle_since]} UTC") >= @publish_started_at
        sleep 0.5
      end
    end

    def result
      @result ||=
      begin
        publish_ops =  @orders_number / (@publish_finished_at - @publish_started_at)
        matching_ops =  @orders_number / (@matching_finished_at - @publish_started_at)

        { config: @config,
          publish_started_at: @publish_started_at,
          publish_finished_at: @publish_finished_at,
          matching_finished_at: @matching_finished_at,
          publish_ops: publish_ops,
          matching_ops: matching_ops }
      end
    end

    def save_results
    end

    # TODO: Use get queue by name.
    def queue_info
      @rmq_http_client.list_queues.find { |q| q.name = AMQPConfig.binding_queue(:matching).first }
    end

    private
    # TODO: Move to Helpers.
    def become_billionaire(member)
      @currencies.each do |c|
        Factories.create(:deposit, member_id: member.id, currency_id: c.id)
      end
    end
  end
end
