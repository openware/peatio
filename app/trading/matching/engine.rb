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

    def submit(order)
      book, counter_book = orderbook.get_books order.type
      match(order, counter_book)
      add_or_cancel(order, book)
    rescue => e
      Rails.logger.error { "Failed to submit order #{order.label}." }
      report_exception(e)
    end

    def cancel(order)
      book, counter_book = orderbook.get_books(order.type)
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

    def match(order, counter_book, attempt_number = 1, maximum_attempts = 3)
      return if attempt_number >= maximum_attempts
      match_implementation(order, counter_book)
    rescue StandardError => e
      report_exception(e) if attempt_number == 1
      match(order, counter_book, attempt_number + 1, maximum_attempts)
    end

    def match_implementation(order, counter_book)
      return if order.filled?
      return unless (counter_order = counter_book.top)

      # trade is price, volume, funds Array.
      trade = order.trade_with(counter_order, counter_book)
      return if trade.blank?

      price, volume, funds = trade

      trade = Trade.new(price, volume, funds)
      trade.validate!

      counter_book.fill_top(price, volume, funds)
      order.fill(price, volume, funds)
      publish(order, counter_order, [price, volume, funds])
      match_implementation(order, counter_book)

    rescue OrderError => e
      report_exception(e)
      cancel(e.order)
    rescue TradeError => e
      report_exception(e)
      cancel(order)
    end

    def add_or_cancel(order, book)
      return if order.filled?
      order.is_a?(LimitOrder) ? book.add(order) : publish_cancel(order)
    end

    def publish(order, counter_order, trade)
      ask, bid = order.type == :ask ? [order, counter_order] : [counter_order, order]

      # Rounding is forbidden in this step because it can cause difference
      # between amount/funds in DB and orderbook.
      price  = trade[0]
      volume = trade[1]
      funds  = trade[2]

      Rails.logger.info { "[#{@market.id}] new trade - ask: #{ask.label} bid: #{bid.label} price: #{price} volume: #{volume} funds: #{funds}" }

      @queue.enqueue(
        :trade_executor,
        {market_id: @market.id, ask_id: ask.id, bid_id: bid.id, strike_price: price, volume: volume, funds: funds},
        {persistent: false}
      )
    end

    def publish_cancel(order)
      @queue.enqueue \
        :order_processor,
        { action: 'cancel', order: order.attributes },
        { persistent: false }
    end

    # min_amount_by_precision - is the smallest positive number which could be
    # rounded to value greater then 0 with precision defined by
    # Market #amount_precision. So min_amount_by_precision is the smallest amount
    # of order/trade for current market.
    # E.g.
    #   market.amount_precision => 4
    #   min_amount_by_precision => 0.0001
    #
    #   market.amount_precision => 2
    #   min_amount_by_precision => 0.01
    #
    def min_amount_by_precision
      0.1.to_d**@market.amount_precision
    end

    def validate_trade

    end
  end
end
