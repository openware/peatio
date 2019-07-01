# encoding: UTF-8
# frozen_string_literal: true

module Workers
  module AMQP
    class OrderProcessor < Base
      def initialize
        Order.where(state: ::Order::PENDING).find_each do |order|
          Order.submit(order.id)
          logger.warn order_id: order.id,
                      message: 'Order with such ID was submitted'
        end
      end

      def process(payload)
        case payload['action']
        when 'submit'
          Order.submit(payload.dig('order', 'id'))
          logger.warn order_id: payload.dig('order', 'id'),
                      message: 'Order with such ID was submitted'
        when 'cancel'
          Order.cancel(payload.dig('order', 'id'))
          logger.warn order_id: payload.dig('order', 'id'),
                      message: 'Order with such ID was canceled'
        end
      rescue StandardError => e
        # Reraise db connection errors to start retry logic.
        if Retry::DB_EXCEPTIONS.any? { |exception| e.is_a?(exception) }
          logger.warn message: 'Lost db connection.'
          raise e
        end

        AMQPQueue.enqueue(:trade_error, e.message)
        report_exception(e)
      end
    end
  end
end
