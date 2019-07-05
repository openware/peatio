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
      if [@price, @volume, @funds].any? { |d| d == ZERO }
        raise TradeError, self, 'price, volume or funds is equal to 0.'
      elsif @price * @volume != @funds
        raise TradeError, self, 'price * volume != funds'
      elsif round(@price * @volume) != round(@funds)
        raise TradeError, self, 'round(@price * @volume) != round(@funds)'
      end
      true
    end

    private
    # TODO: Move this method.
    def round(d)
      d.round(Market::DB_DECIMAL_PRECISION, BigDecimal::ROUND_DOWN)
    end
  end
end
