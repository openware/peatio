# encoding: UTF-8
# frozen_string_literal: true

module Workers
  module AMQP
    class TradeExecutor < Base
      def process(payload)
        logger.warn message: "Received #{payload}"

        ::Matching::Executor.new(payload.symbolize_keys).execute
      end
    end
  end
end
