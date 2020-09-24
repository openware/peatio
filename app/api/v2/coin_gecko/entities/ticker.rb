# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module CoinGecko
      module Entities
        class Ticker < API::V2::Entities::Base
          expose(
              :ticker_id,
              documentation: {
                  type: String,
                  desc: 'A market ID with delimiter.'
              }
          )

          expose(
              :base_currency,
              documentation: {
                  type: String,
                  desc: 'A currency code of the base asset.'
              }
          )

          expose(
              :target_currency,
              documentation: {
                  type: String,
                  desc: 'A currency code of the quote asset.'
              }
          )

          expose(
              :last_price,
              documentation: {
                  type: BigDecimal,
                  desc: 'The last executed trade price.'
              }
          )

          expose(
              :base_volume,
              documentation: {
                  type: BigDecimal,
                  desc: '24 hour trading volume in base pair volume.'
              }
          )

          expose(
              :target_volume,
              documentation: {
                  type: BigDecimal,
                  desc: '24 hour trading volume in base pair volume.'
              }
          )

          expose(
              :bid,
              documentation: {
                  type: BigDecimal,
                  desc: 'Current highest bid price.'
              }
          )

          expose(
              :ask,
              documentation: {
                  type: BigDecimal,
                  desc: 'Current lowest ask price.'
              }
          )

          expose(
              :high,
              documentation: {
                  type: BigDecimal,
                  desc: 'The highest trade price during last 24 hours (0.0 if no trades executed during last 24 hours).'
              }
          )

          expose(
              :low,
              documentation: {
                  type: BigDecimal,
                  desc: 'The lowest trade price during last 24 hours (0.0 if no trades executed during last 24 hours).'
              }
          )
        end
      end
    end
  end
end
