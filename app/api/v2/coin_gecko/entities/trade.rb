# frozen_string_literal: true

module API
  module V2
    module CoinGecko
      module Entities
        class HistoricalTrade < API::V2::Entities::Base
          expose(
            :trade_id,
            documentation: {
              type: String,
              desc: 'A pair such as "BTC_ETH", with delimiter between different cryptoassets.'
            }
          ) do |trade|
            trade[:id]
          end

          expose(
            :price,
            documentation: {
              type: BigDecimal,
              desc: 'Transaction price in base pair volume.'
            }
          ) do |trade|
            trade[:price]
          end

          expose(
            :base_volume,
            documentation: {
              type: BigDecimal,
              desc: 'Transaction amount in base pair volume.'
            }
          ) do |trade|
            trade[:amount]
          end

          expose(
            :target_volume,
            documentation: {
              type: BigDecimal,
              desc: 'Transaction amount in target pair volume.'
            }
          ) do |trade|
            trade[:total]
          end

          expose(
            :trade_timestamp,
            documentation: {
              type: Integer,
              desc: 'Unix timestamp in milliseconds for when the transaction occurred.'
            }
          ) do |trade|
            trade[:created_at] * MILLISECONDS_IN_SECOND
          end

          expose(
            :type,
            documentation: {
              type: String,
              desc: 'To indicate nature of trade - buy/sell.'
            }
          ) do |trade|
            trade[:taker_type]
          end
        end
      end
    end
  end
end
