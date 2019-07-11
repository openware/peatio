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

  class TradeError < Error

    attr_reader :trade

    def initialize(trade, message=nil)
      @trade = trade
      super message
    end
  end

  # TODO: Use OrderError & TradeError instead of
  # NotEnoughVolume, ExceedSumLimit, TradeExecutionError.
  class NotEnoughVolume     < StandardError; end
  class ExceedSumLimit      < StandardError; end
  class TradeExecutionError < StandardError
    attr_accessor :options

    def initialize(options = {})
      self.options = options
    end
  end
end
