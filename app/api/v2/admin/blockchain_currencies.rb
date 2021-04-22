# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      class BlockchainCurrencies < Grape::API

        get '/blockchains_currencies' do
          admin_authorize! :read, ::BlockchainCurrency

          result = ::BlockchainCurrency.ordered
          present paginate(result), with: API::V2::Admin::Entities::BlockchainCurrency
        end

        desc 'Update blockchain currency.' do
          success API::V2::Admin::Entities::BlockchainCurrency
        end
        params do
          requires :id,
                   desc: -> { API::V2::Admin::Entities::BlockchainCurrency.documentation[:id][:desc] }
          requires :currency_id,
                   values: { value: -> { ::Currency.codes }, message: 'admin.blockchain_currency.currency.doesnt_exist' },
                   desc: -> { API::V2::Admin::Entities::BlockchainCurrency.documentation[:code][:desc] }
          requires :blockchain_key,
                   values: { value: -> { ::Blockchain.pluck(:key) }, message: 'admin.blockchain_currency.blockchain_key_doesnt_exist' },
                   desc: -> { API::V2::Admin::Entities::BlockchainCurrency.documentation[:blockchain_key][:desc] }
          optional :deposit_fee,
                   type: { value: BigDecimal, message: 'admin.blockchain_currency.non_decimal_deposit_fee' },
                   values: { value: ->(p) { p >= 0 }, message: 'admin.blockchain_currency.invalid_deposit_fee' },
                   default: 0.0,
                   desc: -> { API::V2::Admin::Entities::BlockchainCurrency.documentation[:deposit_fee][:desc] }
          optional :min_deposit_amount,
                   type: { value: BigDecimal, message: 'admin.blockchain_currency.min_deposit_amount' },
                   values: { value: ->(p) { p >= 0 }, message: 'admin.blockchain_currency.min_deposit_amount' },
                   default: 0.0,
                   desc: -> { API::V2::Admin::Entities::BlockchainCurrency.documentation[:min_deposit_amount][:desc] }
          optional :min_collection_amount,
                   type: { value: BigDecimal, message: 'admin.blockchain_currency.non_decimal_min_collection_amount' },
                   values: { value: ->(p) { p >= 0 }, message: 'admin.blockchain_currency.invalid_min_collection_amount' },
                   default: 0.0,
                   desc: -> { API::V2::Admin::Entities::BlockchainCurrency.documentation[:min_collection_amount][:desc] }
          optional :withdraw_fee,
                   type: { value: BigDecimal, message: 'admin.blockchain_currency.non_decimal_withdraw_fee' },
                   values: { value: ->(p) { p >= 0 }, message: 'admin.blockchain_currency.ivalid_withdraw_fee' },
                   default: 0.0,
                   desc: -> { API::V2::Admin::Entities::BlockchainCurrency.documentation[:withdraw_fee][:desc] }
          optional :min_withdraw_amount,
                   type: { value: BigDecimal, message: 'admin.blockchain_currency.non_decimal_min_withdraw_amount' },
                   values: { value: ->(p) { p >= 0 }, message: 'admin.blockchain_currency.invalid_min_withdraw_amount' },
                   default: 0.0,
                   desc: -> { API::V2::Admin::Entities::BlockchainCurrency.documentation[:min_withdraw_amount][:desc] }
        end
        post '/blockchains_currencies/update' do
          admin_authorize! :update, ::BlockchainCurrency, params.except(:id)

          blockchain_currency = BlockchainCurrency.find(params[:id])
          if blockchain_currency.update(declared(params, include_missing: false))
            present blockchain_currency, with: API::V2::Admin::Entities::BlockchainCurrency
          else
            body errors: blockchain_currency.errors.full_messages
            status 422
          end
        end
      end
    end
  end
end

