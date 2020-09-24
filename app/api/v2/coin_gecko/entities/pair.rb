# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module CoinGecko
      module Entities
        class Pair < API::V2::Entities::Base
          expose(
              :ticker_id,
              documentation: {
                  type: String,
                  desc: 'A market ID with delimiter.'
              }
          ) do |market|
            "#{market[:base_unit].upcase}_#{market[:quote_unit].upcase}"
          end

          expose(
              :base,
              documentation: {
                  type: String,
                  desc: 'A currency code of the base asset.'
              }
          ) do |market|
            market[:base_unit].upcase
          end

          expose(
              :target,
              documentation: {
                  type: String,
                  desc: 'A currency code of the quote asset.'
              }
          ) do |market|
            market[:quote_unit].upcase
          end
        end
      end
    end
  end
end
