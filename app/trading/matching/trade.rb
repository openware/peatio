# encoding: UTF-8
# frozen_string_literal: true

module Matching
  # TODO: Use Trade instead of price, volume, funds array.
  class Trade
    attr_reader :price, :volume, :funds
    def initialize(price, volume, funds)
      @price = price
      @volume = volume
      @funds = funds
    end

    def validate!
      message =
        if [@price, @volume, @funds].any? { |d| d == ZERO }
          'price, volume or funds is equal to 0.'
        elsif @price * @volume != @funds
          'price * volume != funds'
        elsif round(@price * @volume) != round(@funds)
          'round(@price * @volume) != round(@funds)'
        end
      message.present? ? raise(TradeError.new(self, message)) : true
    end

    private
    # TODO: Move this method.
    def round(d)
      d.round(Market::DB_DECIMAL_PRECISION, BigDecimal::ROUND_DOWN)
    end
  end
end
