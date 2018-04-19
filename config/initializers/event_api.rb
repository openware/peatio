require 'active_support/lazy_load_hooks'

module EventAPI
  class << self
    def notify(event_name, event_payload, options = {})
      arguments = [event_name, event_payload, options]
      middlewares.each do |middleware|
        returned_value = middleware.call(*arguments)
        case returned_value
          when Array then arguments = returned_value
          else return returned_value
        end
      rescue StandardError => e
        report_exception(e)
        raise
      end
    end

    def middlewares=(list)
      @middlewares = list
    end

    def middlewares
      @middlewares || []
    end
  end

  module ActiveRecordExtension
    def notify()

    end
  end

  module Middlewares
    class IncludeEventMetadata

    end

    class GenerateJWT
      def call(event_name, event_payload, options)
        [event_name, event_payload, options]
      end
    end

    class PrintToScreen
      def call

      end
    end

    class PublishToRabbitMQ
      def call

      end
    end
  end

  class MetadataMiddleware
    def call(event_name, event_payload, options = {})
      [event_name, event_payload, options]
    end
  end

  class RabbitMQMiddleware
    def call(event_name, event_payload, options = {})
      [event_name, event_payload, options]
    end
  end

  class LoggingMiddleware
    def call(event_name, event_payload, options = {})
      Rails.logger.debug do
        ['', event_name, '', event_payload.to_json, ''].join("\n")
      end
      [event_name, event_payload, options]
    end
  end
end

ActiveSupport.on_load(:active_record) { ActiveRecord::Base.include EventAPI::ActiveRecordExtension }
