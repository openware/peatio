# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Entities
      class Position < Base
        expose :id, documentation: { type: Integer, desc: "Unique order id." }
        expose :market_id, 
               as: :market, 
               documentation: { 
                 desc: "The market in which the order is placed, e.g. 'btcusd'. All available markets can be found at /api/v2/markets.", 
                 type: String,
               }
        expose :avg_price, 
               documentation: { 
                desc: "Average execution price, average of price in trades.",
                type: BigDecimal,
               } do |position, options|
          (position.credit / position.volume).abs
        end

        expose :volume,
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
end
