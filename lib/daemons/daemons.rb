# encoding: UTF-8
# frozen_string_literal: true

require File.join(ENV.fetch('RAILS_ROOT'), 'config', 'environment')

raise "Worker name must be provided." if ARGV.size == 0

name = ARGV[0]
worker = "Workers::Daemons::#{name.camelize}".constantize.new

terminate = proc do
  puts "Terminating worker .."
  worker.stop
  puts "Stopped."
end

Signal.trap("INT",  &terminate)
Signal.trap("TERM", &terminate)

begin
  worker.run
rescue StandardError => e
  if e.is_a?(Bunny::TCPConnectionFailedForAllHosts) || e.is_a?(Bunny::ConnectionClosedError)
    unless Retry.rmq
      Rails.logger.warn { "Killing worker due to rabbitmq lost connection..." }
      raise e
    end

    retry
  end

  if e.cause.is_a?(Mysql2::Error) || e.is_a?(Mysql2::Error::ConnectionError)
    unless Retry.db
      Rails.logger.warn { "Killing worker due to db lost connection..." }
      raise e
    end

    retry
  end
  report_exception(e)
end
