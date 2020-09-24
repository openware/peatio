# encoding: UTF-8
# frozen_string_literal: true


module API
  module V2
    module CoinGecko
      module Entities
        class Orderbook < API::V2::Entities::Base
          expose(
              :ticker_id,
              documentation: {
                  type: String,
                  desc: 'A market ID with delimiter.'
              }
          )

          expose(
              :timestamp,
              documentation: {
                  type: Integer,
                  desc: 'Unix timestamp in milliseconds for when the last updated time occurred'
              }
          )

          expose(
              :asks,
              documentation: {
                  type: BigDecimal,
                  is_array: true,
                  desc: 'Asks in orderbook'
              }
          )

          expose(
              :bids,
              documentation: {
                  type: BigDecimal,
                  is_array: true,
                  desc: 'Bids in orderbook'
              }
          )
        end
      end
    end
  end
end
