# encoding: UTF-8
# frozen_string_literal: true

module Workers
  module AMQP
    class Base

      def logger
        @logger ||= TaggedLogger.new(Rails.logger, worker: self.class)
      end

      def process(_payload)
        method_not_implemented
      end
    end
  end
end
