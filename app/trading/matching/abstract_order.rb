module Matching
  # TODO: doc.
  class AbstractOrder
    def initialize
      method_not_implemented
    end

    def trade_with(_counter_order, _counter_book)
      method_not_implemented
    end

    def fill(trade_price, trade_volume, trade_funds)
      method_not_implemented
    end

    def filled?
      method_not_implemented
    end

    def label
      method_not_implemented
    end

    def valid?
      method_not_implemented
    end

    def attributes
      method_not_implemented
    end
  end
end
