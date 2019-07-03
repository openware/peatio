#encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      module CurrencyParams
        extend ::Grape::API::Helpers

        params :create_currency_params do
          requires :id,
                   type: String,
                   desc: -> { API::V2::Admin::Entities::Currency.documentation[:id][:desc] }
          requires :symbol,
                   type: String,
                   desc: -> { API::V2::Admin::Entities::Currency.documentation[:symbol][:desc] }
          optional :name,
                   type: String,
                   desc: -> { API::V2::Admin::Entities::Currency.documentation[:name][:desc] }
          optional :type,
                   type: String,
                   values: { value: ::Currency.types.map(&:to_s), message: 'admin.currency.invalid_type' },
                   default: 'coin',
                   desc: -> { API::V2::Admin::Entities::Currency.documentation[:type][:desc] }
          given type: ->(val) { val == 'coin' } do
            requires :blockchain_key,
                     type: String,
                     values: { value: -> { ::Blockchain.pluck(:key) }, message: 'admin.currency.blockchain_key_doesnt_exist' },
                     desc: -> { API::V2::Admin::Entities::Currency.documentation[:blockchain_key][:desc] }
          end
          optional :deposit_fee,
                   type: { value: BigDecimal, message: 'admin.currency.non_decimal_deposit_fee' },
                   values: { value: -> (p){ p >= 0 }, message: 'admin.currency.invalid_deposit_fee' },
                   default: 0.0,
                   desc: -> { API::V2::Admin::Entities::Currency.documentation[:deposit_fee][:desc] }
          optional :min_deposit_amount,
                   type: { value: BigDecimal, message: 'admin.currency.non_decimal_deposit_fee' },
                   values: { value: -> (p){ p >= 0 }, message: 'admin.currency.invalid_deposit_fee' },
                   default: 0.0,
                   desc: -> { API::V2::Admin::Entities::Currency.documentation[:deposit_fee][:desc] }
          optional :min_collection_amount,
                   type: { value: BigDecimal, message: 'admin.currency.non_decimal_min_collection_amount' },
                   values: { value: -> (p){ p >= 0 }, message: 'admin.currency.invalid_min_collection_amount' },
                   default: 0.0,
                   desc: -> { API::V2::Admin::Entities::Currency.documentation[:min_collection_amount][:desc] }
          optional :withdraw_fee,
                   type: { value: BigDecimal, message: 'admin.currency.non_decimal_withdraw_fee' },
                   values: { value: -> (p){ p >= 0  }, message: 'admin.currency.ivalid_withdraw_fee' },
                   default: 0.0,
                   desc: -> { API::V2::Admin::Entities::Currency.documentation[:withdraw_fee][:desc] }
          optional :min_withdraw_amount,
                   type: { value: BigDecimal, message: 'admin.currency.non_decimal_min_withdraw_amount' },
                   values: { value: -> (p){ p >= 0 }, message: 'admin.currency.invalid_min_withdraw_amount' },
                   default: 0.0,
                   desc: -> { API::V2::Admin::Entities::Currency.documentation[:min_withdraw_amount][:desc] }
          optional :withdraw_limit_24h,
                   type: { value: BigDecimal, message: 'admin.currency.non_decimal_withdraw_limit_24h' },
                   values: { value: -> (p){ p >= 0 }, message: 'admin.currency.invalid_withdraw_limit_24h' },
                   default: 0.0,
                   desc: -> { API::V2::Admin::Entities::Currency.documentation[:withdraw_limit_24h][:desc] }
          optional :withdraw_limit_72h,
                   type: { value: BigDecimal, message: 'admin.currency.non_decimal_withdraw_limit_72h' },
                   values: { value: -> (p){ p >= 0 }, message: 'admin.currency.invalid_withdraw_limit_72h' },
                   default: 0.0,
                   desc: -> { API::V2::Admin::Entities::Currency.documentation[:withdraw_limit_72h][:desc] }
          optional :position,
                   type: { value: Integer, message: 'admin.currency.non_integer_position' },
                   default: 0,
                   desc: -> { API::V2::Admin::Entities::Currency.documentation[:position][:desc] }
          optional :options,
                   type: { value: JSON, message: 'admin.currency.non_json_options' },
                   default: {},
                   desc: -> { API::V2::Admin::Entities::Currency.documentation[:options][:desc] }
          optional :enabled,
                   type: { value: Boolean, message: 'admin.currency.non_boolean_enabled' },
                   default: true,
                   desc: -> { API::V2::Admin::Entities::Currency.documentation[:enabled][:desc] }
          optional :base_factor,
                   type: { value: Integer, message: 'admin.currency.non_integer_base_factor' },
                   default: 1,
                   desc: -> { API::V2::Admin::Entities::Currency.documentation[:base_factor][:desc] }
          optional :precision,
                   type: { value: Integer, message: 'admin.currency.non_integer_base_precision' },
                   default: 8,
                   desc: -> { API::V2::Admin::Entities::Currency.documentation[:precision][:desc] }
          optional :icon_url,
                   type: String,
                   desc: -> { API::V2::Admin::Entities::Currency.documentation[:icon_url][:desc] }
        end

        params :update_currency_params do
          requires :id,
                   type: String,
                   values: { value: -> { ::Currency.ids }, message: 'admin.currency.doesnt_exist' },
                   desc: -> { API::V2::Admin::Entities::Currency.documentation[:id][:desc] }
          optional :symbol,
                   type: String,
                   desc: -> { API::V2::Admin::Entities::Currency.documentation[:symbol][:desc] }
          optional :name,
                   type: String,
                   desc: -> { API::V2::Admin::Entities::Currency.documentation[:name][:desc] }
          optional :blockchain_key,
                   type: String,
                   values: { value: -> { ::Blockchain.pluck(:key) }, message: 'admin.currency.blockchain_key_doesnt_exist' },
                   desc: -> { API::V2::Admin::Entities::Currency.documentation[:blockchain_key][:desc] }
          optional :deposit_fee,
                   type: { value: BigDecimal, message: 'admin.currency.non_decimal_deposit_fee' },
                   values: { value: -> (p){ p >= 0 }, message: 'admin.currency.invalid_deposit_fee' },
                   desc: -> { API::V2::Admin::Entities::Currency.documentation[:deposit_fee][:desc] }
          optional :min_deposit_amount,
                   type: { value: BigDecimal, message: 'admin.currency.non_decimal_deposit_fee' },
                   values: { value: -> (p){ p >= 0 }, message: 'admin.currency.invalid_deposit_fee' },
                   desc: -> { API::V2::Admin::Entities::Currency.documentation[:deposit_fee][:desc] }
          optional :min_collection_amount,
                   type: { value: BigDecimal, message: 'admin.currency.non_decimal_min_collection_amount' },
                   values: { value: -> (p){ p >= 0 }, message: 'admin.currency.invalid_min_collection_amount' },
                   desc: -> { API::V2::Admin::Entities::Currency.documentation[:min_collection_amount][:desc] }
          optional :withdraw_fee,
                   type: { value: BigDecimal, message: 'admin.currency.non_decimal_withdraw_fee' },
                   values: { value: -> (p){ p >= 0  }, message: 'admin.currency.invalid_withdraw_fee' },
                   desc: -> { API::V2::Admin::Entities::Currency.documentation[:withdraw_fee][:desc] }
          optional :min_withdraw_amount,
                   type: { value: BigDecimal, message: 'admin.currency.non_decimal_min_withdraw_amount' },
                   values: { value: -> (p){ p >= 0 }, message: 'admin.currency.invalid_min_withdraw_amount' },
                   desc: -> { API::V2::Admin::Entities::Currency.documentation[:min_withdraw_amount][:desc] }
          optional :withdraw_limit_24h,
                   type: { value: BigDecimal, message: 'admin.currency.non_decimal_withdraw_limit_24h' },
                   values: { value: -> (p){ p >= 0 }, message: 'admin.currency.invalid_withdraw_limit_24h' },
                   desc: -> { API::V2::Admin::Entities::Currency.documentation[:withdraw_limit_24h][:desc] }
          optional :withdraw_limit_72h,
                   type: { value: BigDecimal, message: 'admin.currency.non_decimal_withdraw_limit_72h' },
                   values: { value: -> (p){ p >= 0 }, message: 'admin.currency.invalid_withdraw_limit_72h' },
                   desc: -> { API::V2::Admin::Entities::Currency.documentation[:withdraw_limit_72h][:desc] }
          optional :position,
                   type: { value: Integer, message: 'admin.currency.non_integer_position' },
                   desc: -> { API::V2::Admin::Entities::Currency.documentation[:position][:desc] }
          optional :options,
                   type: { value: JSON, message: 'admin.currency.non_json_options' },
                   desc: -> { API::V2::Admin::Entities::Currency.documentation[:options][:desc] }
          optional :enabled,
                   type: { value: Boolean, message: 'admin.currency.non_boolean_enabled' },
                   desc: -> { API::V2::Admin::Entities::Currency.documentation[:enabled][:desc] }
          optional :base_factor,
                   type: { value: Integer, message: 'admin.currency.non_integer_base_factor' },
                   desc: -> { API::V2::Admin::Entities::Currency.documentation[:base_factor][:desc] }
          optional :precision,
                   type: { value: Integer, message: 'admin.currency.non_integer_base_precision' },
                   desc: -> { API::V2::Admin::Entities::Currency.documentation[:precision][:desc] }
          optional :icon_url,
                   type: String,
                   desc: -> { API::V2::Admin::Entities::Currency.documentation[:icon_url][:desc] }
        end
      end
    end
  end
end
