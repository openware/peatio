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
                    "be found at /api/v2/admin/markets."
            }
          )

          expose(
            :base_unit,
            documentation: {
              type: String,
              desc: 'Market base(ask) unit.'
            }
          )

          expose(
            :quote_unit,
            documentation: {
              type: String,
              desc: 'Market quote(bid) unit.'
            }
          )

          expose(
            :ask_fee,
            documentation: {
              type: BigDecimal,
              desc: 'Market ask fee.'
            }
          )

          expose(
            :bid_fee,
            documentation: {
              type: BigDecimal,
              desc: 'Market bid fee.'
            }
          )

          expose(
            :min_price,
            documentation: {
              type: BigDecimal,
              desc: 'Min order price.'
            }
          )

          expose(
            :max_price,
            documentation: {
              type: BigDecimal,
              desc: 'Max order price.'
            }
          )

          expose(
            :min_amount,
            documentation: {
              type: BigDecimal,
              desc: 'Min order amount.'
            }
          )

          expose(
            :amount_precision,
            documentation: {
              type: Integer,
              desc: 'Amount precision.'
            }
          )

          expose(
            :price_precision,
            documentation: {
              type: Integer,
              desc: 'Price precision.'
            }
          )

          expose(
            :position,
            documentation: {
              type: Integer,
              desc: 'Market position.'
            }
          )

          expose(
            :state,
            documentation: {
              type: String,
              desc: "Market state, one of #{::Market::STATES}."
            }
          )

          expose(
            :created_at,
            format_with: :iso8601,
            documentation: {
              type: String,
              desc: 'Market created time in iso8601 format.'
            }
          )

          expose(
            :updated_at,
            format_with: :iso8601,
            documentation: {
              type: String,
              desc: 'Market updated time in iso8601 format.'
            }
          )
        end
      end
    end
  end
end
