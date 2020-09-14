# frozen_string_literal: true

module API
  module V2
    module OrderHelpers

      THIRD_PARTY_ORDER_CANCEL_TYPE = {
          'single' => 3,
          'bulk'   => 4
      }.freeze

      def build_order(attrs)
        (attrs[:side] == 'sell' ? OrderAsk : OrderBid).new \
          state:         ::Order::PENDING,
          member:        current_user,
          ask:           current_market&.base_unit,
          bid:           current_market&.quote_unit,
          market:        current_market,
          ord_type:      attrs[:ord_type] || 'limit',
          price:         attrs[:price],
          volume:        attrs[:volume],
          origin_volume: attrs[:volume]
      end

      def check_balance(order)
        current_user.get_account(order.currency).balance >= order.locked
      end

      def compute_locked(order)
        balance = current_user.get_account(order.currency).balance
        compute_locked = order.compute_locked
        raise ::Account::AccountError if balance < compute_locked 

        # For Buy market order we use locking_buffer to cover 10% price change
        # during order execution if user will request 100% order
        # we will lock all user balance without locking_buffer
        order.locked = order.origin_locked = [compute_locked * OrderBid::LOCKING_BUFFER_FACTOR, balance].min
      end

      def create_order(attrs)
        create_order_errors = {
          ::Account::AccountError => 'market.account.insufficient_balance',
          ::Order::InsufficientMarketLiquidity => 'market.order.insufficient_market_liquidity',
          ActiveRecord::RecordInvalid => 'market.order.invalid_volume_or_price'
        }

        order = build_order(attrs)
        submit_order(order)
        order
        # TODO: Make more specific error message for ActiveRecord::RecordInvalid.
      rescue StandardError => e
        if create_order_errors.include?(e.class)
          report_api_error(e, request)
        else
          report_exception(e)
        end

        message = create_order_errors.fetch(e.class, 'market.order.create_error')
        error!({ errors: [message] }, 422)
      end

      def submit_order(order)
        if order.ord_type == 'market' && order.side == 'buy'
          compute_locked(order)
        else
          order.locked = order.origin_locked = order.compute_locked
        end

        raise ::Account::AccountError unless check_balance(order)

        order.save!

        # FIXME: Need to send the message to third-party engine.
        AMQP::Queue.enqueue(:order_processor,
                          { action: 'submit', order: order.attributes },
                          { persistent: false })

      end

      def cancel_order(order)
        market_engine = order.market.engine

        if market_engine.peatio_engine?
          cancel_peatio_order(order)
        else
          cancel_third_party_order(market_engine.driver, order)
        end
      end

      def cancel_peatio_order(order)
        AMQP::Queue.enqueue(:matching, action: 'cancel', order: order.to_matching_attributes)
      end

      def cancel_third_party_order(engine_driver, order)
        AMQP::Queue.publish(engine_driver,
                            data: order.as_json_for_third_party,
                            type: THIRD_PARTY_ORDER_CANCEL_TYPE['single'])
      end

      def bulk_cancel_third_party_orders(engine_driver, filters = {})
        AMQP::Queue.publish(engine_driver,
                            data: filters,
                            type: THIRD_PARTY_ORDER_CANCEL_TYPE['bulk'])
      end

      def order_param
        params[:order_by].downcase == 'asc' ? 'id asc' : 'id desc'
      end
    end
  end
end
