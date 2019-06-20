# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      module Entities
        class Market < Base
          expose(
            :id,
            documentation: {
              type: String,
              desc: "Unique market id. It's always in the form of xxxyyy,"\
                    "where xxx is the base currency code, yyy is the quote"\
                    "currency code, e.g. 'btcusd'. All available markets can"\
                    "be found at /api/v2/markets."
            }
          )

          expose(
            :ask_unit,
            documentation: {
              type: String,
              desc: "Market ask unit."
            }
          )

          expose(
            :bid_unit,
            documentation: {
              type: String,
              desc: "Market bid unit."
            }
          )

          expose(
            :ask_fee,
            documentation: {
              type: BigDecimal,
              desc: "Market ask fee."
            }
          )

          expose(
            :bid_fee,
            documentation: {
              type: BigDecimal,
              desc: "Market bid fee."
            }
          )

          expose(
            :min_ask_price,
            documentation: {
              type: BigDecimal,
              desc: "Max ask order price."
            }
          )

          expose(
            :max_bid_price,
            documentation: {
              type: BigDecimal,
              desc: "Max bid order price."
            }
          )

          expose(
            :min_ask_amount,
            documentation: {
              type: BigDecimal,
              desc: "Min ask order amount."
            }
          )

          expose(
            :min_bid_amount,
            documentation: {
              type: BigDecimal,
              desc: "Min bid order amount."
            }
          )

          expose(
            :ask_precision,
            documentation: {
              type: BigDecimal,
              desc: "Precision for ask order."
            }
          )

          expose(
            :bid_precision,
            documentation: {
              type: BigDecimal,
              desc: "Precision for bid order."
            }
          )

          expose(
            :position,
            documentation: {
              type: Integer,
              desc: 'Market position'
            }
          )

          expose(
            :enabled,
            documentation: {
              type: String,
              desc: 'Market display'
            }
          )

          expose(
            :created_at,
            format_with: :iso8601,
            documentation: {
              type: String,
              desc: 'Currency created time in iso8601 format'
            }
          )

          expose(
            :updated_at,
            format_with: :iso8601,
            documentation: {
              type: String,
              desc: 'Currency updated time in iso8601 format'
            }
          )
        end
      end
    end
  end
end
