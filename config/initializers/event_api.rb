require 'active_support/concern'
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
      @middlewares ||= []
    end
  end

  module ActiveRecordExtension
    extend ActiveSupport::Concern

    included do
      # We add «after_commit» callbacks immediately after inclusion.
      after_commit on: :create, prepend: true do
        notify_record_created
      end

      after_commit on: :update, prepend: true do
        notify_record_updated
      end
    end

    module ClassMethods
      def notifies_about_events(options = {})
        @event_api_behavior = event_api_behavior.merge(options)
      end

      def event_api_behavior
        @event_api_behavior || superclass.instance_variable_get(:@event_api_behavior) || {}
      end
    end

    def to_event_api_payload
      as_json
    end

    def notify(partial_event_name, event_payload)
      tokens = ['model']
      tokens << self.class.event_api_behavior.fetch(:prefix) { self.class.name.underscore.gsub(/\//, '_') }
      tokens << partial_event_name.to_s
      full_event_name = tokens.join('.')
      EventAPI.notify(full_event_name, event_payload)
    end

    def notify_record_created
      notify(:created, record: to_event_api_payload)
    end

    def notify_record_updated
      current_record  = self
      previous_record = dup
      previous_changes.each { |attribute, values| previous_record.send("#{attribute}=", values.first) }

      previous_record.created_at ||= current_record.created_at

      before = previous_record.to_event_api_payload.compact
      after  = current_record.to_event_api_payload.compact

      notify :updated, \
        record:  after,
        changes: before.delete_if { |attribute, value| after[attribute] == value }
    end
  end

  module Middlewares
    class IncludeEventMetadata
      def call(event_name, event_payload, options)
        event_payload[:name] = event_name
        [event_name, event_payload, options]
      end
    end

    class GenerateJWT
      def call(event_name, event_payload, options)
        [event_name, event_payload, options]
      end
    end

    class PrintToScreen
      def call(event_name, event_payload, options = {})
        Rails.logger.debug do
          ['',
           'Produced new event at ' + Time.current.to_s + ': ',
           'name    = ' + event_name,
           'payload = ' + event_payload.to_json,
           ''].join("\n")
        end
        [event_name, event_payload, options]
      end
    end

    class PublishToAbstractRabbitMQ
      def call(event_name, event_payload, options)
        Rails.logger.debug do
          ['',
           'Published new message to RabbitMQ (abstractly):',
           'exchange    = ' + exchange_name(event_name),
           'routing key = ' + routing_key(event_name),
           'payload     = ' + event_payload.to_json,
           ''
          ].join("\n")
        end
        [event_name, event_payload, options]
      end

    private
      # TODO: Validate.
      def exchange_name(event_name)
        "peatio.events.#{event_name.split('.').first}"
      end

      def routing_key(event_name)
        event_name.split('.').drop(1).join('.')
      end
    end
  end

  middlewares << Middlewares::IncludeEventMetadata.new
  middlewares << Middlewares::PrintToScreen.new
  middlewares << Middlewares::PublishToAbstractRabbitMQ.new
end

ActiveSupport.on_load(:active_record) { ActiveRecord::Base.include EventAPI::ActiveRecordExtension }
