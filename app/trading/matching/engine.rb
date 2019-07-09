# encoding: UTF-8
# frozen_string_literal: true

module Matching
  class Engine

    attr :orderbook, :mode, :queue
    delegate :ask_orders, :bid_orders, to: :orderbook

    def initialize(market, options={})
      @market    = market
      @orderbook = OrderBookManager.new(market.id)

      # Engine is able to run in different mode:
      # dryrun: do the match, do not publish the trades
      # run:    do the match, publish the trades (default)
      shift_gears(options[:mode] || :run)
    end

    def submit2(order)
      Rails.logger.warn 'Submit 2'
      messages = match2(order)
      messages.each do |m|
        queue.enqueue(*m)
      end
    end

    def match2(order)
      book, opposite_book = orderbook.get_books(order.type)

      messages = []
      loop do
        # If order is fulfilled we break the loop.
        break if order.filled?

        if opposite_book.top.blank?
          if order.is_a?(LimitOrder)
            book.add(order)
          else
            messages << order_cancel_message(order)
          end
          break
        end

        opposite_order = opposite_book.top
        trade = order.trade_with(opposite_order, opposite_book)

        if trade.blank?
          if order.is_a?(LimitOrder)
            book.add(order)
          else
            messages << order_cancel_message(order)
          end
          break
        end

        price, volume, funds = trade
        Matching::Trade.new(price, volume, funds).validate!

        order.fill(price, volume, funds)
        opposite_book.fill_top(price, volume, funds)

        messages << trade_message(order, opposite_order, trade)
      end

      messages
    rescue TradeError => e
      # TODO: Decide what do we need to do with such pair of orders.
      # TODO: Log error.
      messages << order_cancel_message(order)
    rescue OrderError => e
      # TODO: Log error.
      messages << order_cancel_message(order)
    end

    def cancel(order)
      book, _counter_book = orderbook.get_books(order.type)
      book.remove(order)
      publish_cancel(order)
    rescue => e
      Rails.logger.error { "Failed to cancel order #{order.label}." }
      report_exception(e)
    end

    def limit_orders
      { ask: ask_orders.limit_orders,
        bid: bid_orders.limit_orders }
    end

    def market_orders
      { ask: ask_orders.market_orders,
        bid: bid_orders.market_orders }
    end

    def shift_gears(mode)
      case mode
      when :dryrun
        @queue = []
        class <<@queue
          def enqueue(*args)
            push args
          end
        end
      when :run
        @queue = AMQPQueue
      else
        raise "Unrecognized mode: #{mode}"
      end

      @mode = mode
    end

    private

    def trade_message(order, counter_order, trade)
      ask, bid = order.type == :ask ? [order, counter_order] : [counter_order, order]

      # NOTE: Rounding is forbidden in this step because it can cause the
      # difference between amount/funds values in DB and orderbook.
      price  = trade[0]
      volume = trade[1]
      funds  = trade[2]

      [:trade_executor,
       { market_id: @market.id,
         ask_id: ask.id,
         bid_id: bid.id,
         strike_price: price,
         volume: volume,
         funds: funds },
       { persistent: false }]
    end

    def order_cancel_message(order)
      [:order_processor,
       { action: 'cancel', order: order.attributes },
       { persistent: false }]
    end

    def publish(order, counter_order, trade)
      ask, bid = order.type == :ask ? [order, counter_order] : [counter_order, order]

      # Rounding is forbidden in this step because it can cause difference
      # between amount/funds in DB and orderbook.
      price  = trade[0]
      volume = trade[1]
      funds  = trade[2]

      Rails.logger.info { "[#{@market.id}] new trade - ask: #{ask.label} bid: #{bid.label} price: #{price} volume: #{volume} funds: #{funds}" }

      @queue.enqueue(*trade_message(order, counter_order, trade))
    end

    def publish_cancel(order)
      @queue.enqueue(*order_cancel_message(order))
    end
  end
end
