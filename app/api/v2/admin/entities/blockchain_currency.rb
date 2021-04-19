# frozen_string_literal: true

module API
  module V2
    module Admin
      module Entities
        class BlockchainCurrency < API::V2::Entities::Base

          expose(
            :id,
            documentation: {
              type: Integer,
              desc: 'Blockchain currency id.'
            }
          )

          expose(
            :blockchain_key,
            documentation: {
              type: String,
              desc: 'Unique id to identify blockchain.'
            }
          )

          expose(
            :currency_id,
            documentation: {
              type: String,
              desc: 'Unique currency code.'
            }
          )

          expose(
            :deposit_fee,
            documentation: {
              type: BigDecimal,
              desc: 'Currency deposit fee.'
            }
          )

          expose(
            :min_deposit_amount,
            documentation: {
              type: BigDecimal,
              desc: 'Minimal deposit amount.'
            }
          )

          expose(
            :min_collection_amount,
            documentation: {
              type: BigDecimal,
              desc: 'Minimal collection amount.'
            }
          )

          expose(
            :withdraw_fee,
            documentation: {
              type: BigDecimal,
              desc: 'Currency withdraw fee.'
            }
          )

          expose(
            :min_withdraw_amount,
            documentation: {
              type: BigDecimal,
              desc: 'Minimal withdraw amount.'
            }
          )

          expose(
            :created_at,
            format_with: :iso8601,
            documentation: {
              type: String,
              desc: 'BlockchainCurrency created time in iso8601 format.'
            }
          )

          expose(
            :updated_at,
            format_with: :iso8601,
            documentation: {
              type: String,
              desc: 'BlockchainCurrency updated time in iso8601 format.'
            }
          )
        end
      end
    end
  end
end
