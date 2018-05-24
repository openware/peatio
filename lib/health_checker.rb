# encoding: UTF-8
# frozen_string_literal: true

module HealthChecker
  HealthCheckError = Class.new(StandardError)

  LIVE_CHECKS = %i[check_db check_redis check_rabbitmq].freeze
  READY_CHECKS = %i[check_db].freeze

  class << self
    def alive
      all_checks_passed? LIVE_CHECKS
    rescue Exception => e
      report_exception(e)
      false
    end

    def ready
      all_checks_passed? READY_CHECKS
    rescue Exception => e
      report_exception(e)
      false
    end

    private

    def all_checks_passed?(checks)
      checks.all? { |m| send(m) }
    end

    def check_db
      Market.exists?
    end

    def check_redis
      result = KlineDB.redis.ping
      result == 'PONG' or raise HealthCheckError, "Redis.ping returned #{result.inspect}"
    end

    def check_rabbitmq
      bunny = Bunny.new(AMQPConfig.connect).tap { |c| c.start }
      return bunny.close if bunny.connected?
      false
    end
  end
end
