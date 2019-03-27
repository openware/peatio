# encoding: UTF-8
# frozen_string_literal: true
require "peatio/mq/events"

module Matching
  class OrderBookManager
    attr_reader :ask_orders,
                :bid_orders

    def self.build_order(attrs)
      attrs.symbolize_keys!

      raise ArgumentError, "Missing ord_type: #{attrs.inspect}" unless attrs[:ord_type].present?

      klass = ::Matching.const_get "#{attrs[:ord_type]}_order".camelize
      klass.new attrs
    end

    def initialize(market, options={})
      @market     = market
      @ask_orders = OrderBook.new(market, :ask, options)
      @bid_orders = OrderBook.new(market, :bid, options)

      @publisher_thread = launch_publisher_thread
    end

    def finalize
      @publisher_thread.exit
    end

    def get_books(type)
      case type
      when :ask
        [@ask_orders, @bid_orders]
      when :bid
        [@bid_orders, @ask_orders]
      end
    end

    private

    def launch_publisher_thread
      @global_market = Global[@market]
      @triggered_publisher_at = 0

      Thread.new do
        loop do
          sleep 0.5
          begin
            trigger_publisher if update_cache || max_time_without_update
          rescue StandardError => error
            # TODO proper error logging
          ensure
            next
          end
        end
      end
    end

    def trigger_publisher
      Peatio::MQ::Events.publish("public", @market, "update", {
        asks: @global_market.asks,
        bids: @global_market.bids,
      })
      @triggered_publisher_at = Time.now.to_i
    end

    def update_cache
      depth_asks_updated = @ask_orders.write_depth_to_cache
      depth_bids_updated = @bid_orders.write_depth_to_cache

      depth_asks_updated || depth_bids_updated
    end

    def max_time_without_update
      Time.now.to_i - @triggered_publisher_at > 30 # seconds
    end
  end
end
