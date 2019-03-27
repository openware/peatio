# encoding: UTF-8
# frozen_string_literal: true
require_relative 'constants'

module Matching
  class OrderBook
    attr_reader :market,
                :side

    def initialize(market, side, options={})
      @market = market
      @side   = side.to_sym

      @updated = true
      @mutex_updated = Mutex.new

      @limit_orders = RBTree.new
      @mutex_limit_orders = Mutex.new

      @market_orders = RBTree.new
      @mutex_market_orders = Mutex.new
    end

    def build_depth
      depth = Hash.new { |h, k| h[k] = 0.to_d }

      price_levels = limit_orders
      price_levels = limit_orders.reverse_each.to_h if side == :bid

      price_levels.each_with_index do |(price, orders), i|
        break unless i < 200 # get only the first 200 price levels

        depth[price] += orders.map(&:volume).sum
      end

      depth.to_a
    end

    def write_depth_to_cache
      @mutex_updated.synchronize do
        return unless @updated

        @updated = false
      end

      market_id = market.is_a?(Market) ? market.id : market
      Rails.cache.write("peatio:#{market_id}:depth:#{side}s", build_depth)
      true
    end

    def best_limit_price
      limit_top&.price
    end

    def limit_top
      @mutex_limit_orders.synchronize do
        return if @limit_orders.empty?

        # Lowest price wins.
        if side == :ask
          _price, level = @limit_orders.first
        else
          # Highest price wins.
          _price, level = @limit_orders.last
        end

        level.top
      end
    end

    def market_top
      @mutex_market_orders.synchronize do
        @market_orders.first[1] unless @market_orders.empty?
      end
    end

    def top
      market_top || limit_top
    end

    def fill_top(trade_price, trade_volume, trade_funds)
      order = top
      raise "No top order in empty book." unless order

      order.fill(trade_price, trade_volume, trade_funds)

      if order.filled?
        remove(order)
        return
      end

      touch_updated
    end

    def find(order)
      case order
      when LimitOrder
        @mutex_limit_orders.synchronize do
          @limit_orders[order.price].find(order.id)
        end
      when MarketOrder
        @mutex_market_orders.synchronize do
          @market_orders[order.id]
        end
      end
    end

    def add(order)
      raise InvalidOrderError, "volume is zero" if order.volume <= ZERO

      case order
      when LimitOrder
        @mutex_limit_orders.synchronize do
          @limit_orders[order.price] ||= PriceLevel.new(order.price)
          @limit_orders[order.price].add(order)
        end
      when MarketOrder
        @mutex_market_orders.synchronize do
          @market_orders[order.id] = order
        end
      else
        raise ArgumentError, "Unknown order type"
      end

      touch_updated
    end

    def remove(order)
      case order
      when LimitOrder
        remove_limit_order(order)
      when MarketOrder
        remove_market_order(order)
      else
        raise ArgumentError, "Unknown order type"
      end
    end

    def limit_orders
      @mutex_limit_orders.synchronize do
        orders = {}
        @limit_orders.keys.each { |k| orders[k] = @limit_orders[k].orders }
        orders
      end
    end

    def market_orders
      @mutex_market_orders.synchronize do
        @market_orders.values
      end
    end

    private

    def remove_limit_order(order)
      @mutex_limit_orders.synchronize do
        price_level = @limit_orders[order.price]
        return unless price_level

        order = price_level.find(order.id) # so we can return fresh order
        return unless order

        price_level.remove(order)
        @limit_orders.delete(order.price) if price_level.empty?
      end
      touch_updated
      order
    end

    def remove_market_order(order)
      @mutex_market_orders.synchronize do
        return unless (order = @market_orders[order.id])

        @market_orders.delete(order.id)
      end
      touch_updated
      order
    end

    def touch_updated
      @mutex_updated.synchronize do
        @updated = true
      end
    end
  end
end
