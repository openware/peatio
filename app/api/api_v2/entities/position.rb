# encoding: UTF-8
# frozen_string_literal: true

module APIv2
  module Entities
    class Position < Base
      expose :id, documentation: "Unique order id."
      expose :market_id, as: :market, documentation: "The market in which the order is placed, e.g. 'btcusd'. All available markets can be found at /api/v2/markets."
      expose :avg_price, documentation: "Average execution price, average of price in trades."  do |position, options|
        (position.credit / position.volume).abs
      end

      expose :volume,
             format_with: :integer,
             documentation: {
               desc: 'Position volume.',
               type: Integer,
             }
      expose :credit,
             format_with: :decimal,
             documentation: {
               desc: 'Position credit in quote unit.',
               type: BigDecimal,
             }
      expose :margin,
             format_with: :decimal,
             documentation: {
               desc: 'Position margin in quote unit.',
               type: BigDecimal,
             }             
    end
  end
end
