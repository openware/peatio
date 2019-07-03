module Matching
  PRICE_PRECISION = 8
  AMOUNT_PRECISION = 8
  FUNDS_PRECISION = 16

  module Helpers

    def round_price(d)
      d.round(PRICE_PRECISION, BigDecimal::ROUND_DOWN)
    end

    def round_amount(d)
      d.round(AMOUNT_PRECISION, BigDecimal::ROUND_DOWN)

    end

    def round_funds(d)
      d.round(FUNDS_PRECISION, BigDecimal::ROUND_DOWN)
    end
  end
end
