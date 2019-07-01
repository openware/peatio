# encoding: UTF-8
# frozen_string_literal: true

module Retry

  # List of exeptions retry mechanism
  DB_EXCEPTIONS = [Mysql2::Error, ActiveRecord::StatementInvalid]
  RABBIT_MQ_EXCEPTIONS = [Bunny::TCPConnectionFailedForAllHosts, Bunny::ConnectionClosedError]

  class << self

    def db(retry_count = 5)
      Rails.logger.warn { 'Try recconecting to db.' }
      1.upto(retry_count) do |i|
        sleep_time = (i**1.5).round
        Rails.logger.warn { "#{i} retry. Waiting for connection #{sleep_time} seconds..." }
        sleep sleep_time
        ActiveRecord::Base.connection.reconnect!
        Rails.logger.warn { 'Connection established' }
        return true
      rescue Mysql2::Error, ActiveRecord::StatementInvalid
        return false if i == retry_count
      end
    end

    def rmq(retry_count = 5)
      Rails.logger.warn { 'Try recconecting to rabbitmq.' }
      1.upto(retry_count) do |i|
        sleep_time = (i**1.5).round
        Rails.logger.warn { "#{i} retry. Waiting for connection #{sleep_time} seconds..." }
        sleep sleep_time
        Bunny.run(AMQPConfig.connect) { |c| c.connected? }
        Rails.logger.warn { 'Connection established' }
        return true
      rescue Bunny::TCPConnectionFailedForAllHosts, Bunny::ConnectionClosedError
        return false if i == retry_count
      end
    end
  end
end
