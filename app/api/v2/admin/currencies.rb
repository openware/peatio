# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      class Currencies < Grape::API
        helpers ::API::V2::Admin::Helpers
        helpers do
          params :currency_params do
            optional :name,
                     desc: -> { API::V2::Admin::Entities::Currency.documentation[:name][:desc] }
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
                     values: { value: -> (p){ p >= 0  }, message: 'admin.currency.ivalid_withdraw_fee' },
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
                     desc: -> { API::V2::Admin::Entities::Currency.documentation[:icon_url][:desc] }
          end
        end

        desc 'Get list of currencies',
          is_array: true,
          success: API::V2::Admin::Entities::Currency
        params do
          use :pagination
          use :currency_type
        end
        get '/currencies' do
          authorize! :read, Currency

          search = Currency.ransack(type_eq: params[:type])
          search.sorts = "#{params[:order_by]} #{params[:ordering]}"

          present paginate(search.result), with: API::V2::Admin::Entities::Currency
        end

        desc 'Get a currency.' do
          success API::V2::Admin::Entities::Currency
        end
        params do
          requires :code,
                   type: String,
                   values: { value: -> { Currency.codes(bothcase: true) }, message: 'admin.currency.doesnt_exist'},
                   desc: -> { API::V2::Admin::Entities::Currency.documentation[:code][:desc] }
        end
        get '/currencies/:code' do
          authorize! :read, Currency

          present Currency.find(params[:code]), with: API::V2::Admin::Entities::Currency
        end

        desc 'Create new currency.' do
          success API::V2::Admin::Entities::Currency
        end
        params do
          use :currency_params
          requires :code,
                   desc: -> { API::V2::Admin::Entities::Currency.documentation[:code][:desc] }
          requires :symbol,
                   desc: -> { API::V2::Admin::Entities::Currency.documentation[:symbol][:desc] }
          optional :type,
                   values: { value: ::Currency.types.map(&:to_s), message: 'admin.currency.invalid_type' },
                   default: 'coin',
                   desc: -> { API::V2::Admin::Entities::Currency.documentation[:type][:desc] }
          given type: ->(val) { val == 'coin' } do
            requires :blockchain_key,
                     values: { value: -> { ::Blockchain.pluck(:key) }, message: 'admin.currency.blockchain_key_doesnt_exist' },
                     desc: -> { API::V2::Admin::Entities::Currency.documentation[:blockchain_key][:desc] }
          end
        end
        post '/currencies/new' do
          authorize! :create, Currency

          currency_params = {
            deposit_fee: 0.0,
            min_deposit_amount: 0.0,
            min_collection_amount: 0.0,
            withdraw_fee: 0.0,
            min_withdraw_amount: 0.0,
            withdraw_limit_24h: 0.0,
            withdraw_limit_72h: 0.0,
            position: 0,
            options: {} ,
            enabled: true,
            base_factor: 1,
            precision: 8,
          }.merge(declared(params, include_missing: false))

          currency = Currency.new(currency_params)
          if currency.save
            present currency, with: API::V2::Admin::Entities::Currency
            status 201
          else
            body errors: currency.errors.full_messages
            status 422
          end
        end

        desc 'Update currency.' do
          success API::V2::Admin::Entities::Currency
        end
        params do
          use :currency_params
          requires :code,
                   values: { value: -> { ::Currency.codes }, message: 'admin.currency.doesnt_exist' },
                   desc: -> { API::V2::Admin::Entities::Currency.documentation[:code][:desc] }
          optional :symbol,
                   desc: -> { API::V2::Admin::Entities::Currency.documentation[:symbol][:desc] }
          optional :blockchain_key,
                   values: { value: -> { ::Blockchain.pluck(:key) }, message: 'admin.currency.blockchain_key_doesnt_exist' },
                   desc: -> { API::V2::Admin::Entities::Currency.documentation[:blockchain_key][:desc] }
        end
        post '/currencies/update' do
          authorize! :write, Currency

          currency = Currency.find(params[:code])
          if currency.update(declared(params, include_missing: false))
            present currency, with: API::V2::Admin::Entities::Currency
          else
            body errors: currency.errors.full_messages
            status 422
          end
        end
      end
    end
  end
end
