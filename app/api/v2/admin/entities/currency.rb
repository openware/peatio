# enco  ding: UTF-8
# froz  en_string_literal: true

module API
  module V2
    module Admin
      module Entities
        class Currency < Base
          expose(
            :id,
            documentation: {
              desc: 'Currency code.',
              type: String,
              values: -> { ::Currency.enabled.codes }
            }
          )

          expose(
              :name,
              documentation: {
                  type: String,
                  desc: 'Currency name'
              },
              if: -> (currency){ currency.name.present? }
          )

          expose(
            :blockchain_key,
            documentation: {
                type: String,
                desc: 'Currency blockchain key'
            },
            if: -> (currency){ currency.coin? }
          )

          expose(
            :symbol,
            documentation: {
              type: String,
              desc: 'Currency symbol'
            }
          )

          expose(
            :explorer_transaction,
            documentation: {
              type: String,
              desc: 'Currency transaction exprorer url template'
            },
            if: -> (currency){ currency.coin? }
          )

          expose(
            :explorer_address,
            documentation: {
              type: String,
              desc: 'Currency address exprorer url template'
            },
            if: -> (currency){ currency.coin? }
          )

          expose(
            :type,
            documentation: {
              type: String,
              values: -> { ::Currency.types },
              desc: 'Currency type'
            }
          )

          expose(
            :deposit_fee,
            documentation: {
              type: BigDecimal,
              desc: 'Currency deposit fee'
            }
          )

          expose(
            :min_deposit_amount,
            documentation: {
              type: BigDecimal,
              desc: 'Minimal deposit amount'
            }
          )

          expose(
            :withdraw_fee,
            documentation: {
              type: BigDecimal,
              desc: 'Currency withdraw fee'
            }
          )

          expose(
            :min_withdraw_amount,
            documentation: {
              type: BigDecimal,
              desc: 'Minimal withdraw amount'
            }
          )

          expose(
            :min_collection_amount,
            documentation: {
              type: BigDecimal,
              desc: 'Minimal collection amount'
            }
          )

          expose(
            :withdraw_limit_24h,
            documentation: {
              type: BigDecimal,
              desc: 'Currency 24h withdraw limit'
            }
          )

          expose(
            :withdraw_limit_72h,
            documentation: {
              type: BigDecimal,
              desc: 'Currency 72h withdraw limit'
            }
          )

          expose(
            :base_factor,
            documentation: {
              type: Integer,
              desc: 'Currency base factor'
            }
          )

          expose(
            :precision,
            documentation: {
              type: Integer,
              desc: 'Currency precision'
            }
          )

          expose(
            :position,
            documentation: {
              type: Integer,
              desc: 'Currency position'
            }
          )

          expose(
            :enabled,
            documentation: {
              type: String,
              desc: 'Currency display'
            }
          )

          expose(
            :icon_url,
            documentation: {
              type: String,
              desc: 'Currency icon'
            },
            if: -> (currency){ currency.icon_url.present? }
          )

          expose(
            :options,
            documentation: {
              type: JSON,
              desc: 'Currency options'
            },
            if: -> (currency){ currency.coin? }
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
