# encoding: UTF-8
# frozen_string_literal: true

module Matching

  ZERO = 0.to_d unless defined?(ZERO)

  Error = Class.new(StandardError)

  class OrderError < Error

    attr_reader :order

    def initialize(order, message=nil)
      @order = order
      super message
    end
  end

  InvalidOrderError = Class.new(OrderError)
  # TODO: Do we need this error?
  MarketOrderExceededFundsError = Class.new(OrderError)

  class TradeError < Error

    attr_reader :trade

    def initialize(trade, message=nil)
      @trade = trade
      super message
    end
  end

  # TODO: Use InvalidOrderError instead of LegacyInvalidOrderError.
  class LegacyInvalidOrderError < StandardError; end
  class NotEnoughVolume     < StandardError; end
  class ExceedSumLimit      < StandardError; end
  class TradeExecutionError < StandardError
    attr_accessor :options

    def initialize(options = {})
      self.options = options
    end
  end
end
