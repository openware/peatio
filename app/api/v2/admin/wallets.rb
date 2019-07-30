# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      class Wallets < Grape::API
        helpers ::API::V2::Admin::Helpers
        helpers do
          params :wallet_params do
            optional :settings,
                     type: { value: JSON, message: 'admin.wallet.non_json_settings' },
                     desc: -> { API::V2::Admin::Entities::Wallet.documentation[:settings][:desc] }
            optional :nsig,
                     type: { value: Integer, message: 'admin.wallet.non_integer_nsig' },
                     desc: -> { API::V2::Admin::Entities::Wallet.documentation[:nsig][:desc] }
            optional :max_balance,
                     type: { value: BigDecimal, message: 'admin.blockchain.non_decimal_max_balance' },
                     values: { value: -> (p){ p >= 0 }, message: 'admin.wallet.invalid_max_balance' },
                     desc: -> { API::V2::Admin::Entities::Wallet.documentation[:max_balance][:desc] }
            optional :parent,
                     type: { value: String, message: 'admin.wallet.non_string_parent'},
                     desc: -> { API::V2::Admin::Entities::Wallet.documentation[:parent][:desc] }
            optional :status,
                     values: { value: %w(active disabled), message: 'admin.wallet.invalid_status' },
                     desc: -> { API::V2::Admin::Entities::Wallet.documentation[:status][:desc] }
          end
        end

        desc 'Get all wallets, result is paginated.',
          is_array: true,
          success: API::V2::Admin::Entities::Wallet
        params do
          use :pagination
        end
        get '/wallets' do
          authorize! :read, Wallet

          search = Wallet.ransack
          search.sorts = "#{params[:order_by]} #{params[:ordering]}"
          present paginate(search.result), with: API::V2::Admin::Entities::Wallet
        end

        desc 'Get a wallet.' do
          success API::V2::Admin::Entities::Wallet
        end
        params do
          requires :id,
                   type: { value: Integer, message: 'admin.wallet.non_integer_id' },
                   desc: -> { API::V2::Admin::Entities::Wallet.documentation[:id][:desc] }
        end
        get '/wallets/:id' do
          authorize! :read, Wallet

          present Wallet.find(params[:id]), with: API::V2::Admin::Entities::Wallet
        end

        desc 'Creates new wallet.' do
          success API::V2::Admin::Entities::Wallet
        end
        params do
          use :wallet_params
          requires :blockchain_key,
                   values: { value: -> { ::Blockchain.pluck(:key) }, message: 'admin.wallet.blockchain_key_doesnt_exist' },
                   desc: -> { API::V2::Admin::Entities::Wallet.documentation[:blockchain_key][:desc] }
          requires :name,
                   desc: -> { API::V2::Admin::Entities::Wallet.documentation[:name][:desc] }
          requires :address,
                   desc: -> { API::V2::Admin::Entities::Wallet.documentation[:address][:desc] }
          requires :currency_id,
                   values: { value: -> { ::Currency.codes }, message: 'admin.wallet.currency_id_doesnt_exist' },
                   desc: -> { API::V2::Admin::Entities::Wallet.documentation[:currency_id][:desc] }
          requires :kind,
                   values: { value: ::Wallet.kind.values, message: 'admin.wallet.invalid_kind' },
                   desc: -> { API::V2::Admin::Entities::Wallet.documentation[:kind][:desc] }
          requires :gateway,
                   values: { value: -> { ::Wallet.gateways.map(&:to_s) }, message: 'admin.wallet.gateway_doesnt_exist' },
                   desc: -> { API::V2::Admin::Entities::Wallet.documentation[:gateway][:desc] }
        end
        post '/wallets/new' do
          authorize! :create, Wallet

          wallet_params = {
            settings: {},
            nsig: 1,
            max_balance: 0.0,
            status: 'active',
          }.merge(declared(params, include_missing: false))

          wallet = Wallet.new(wallet_params)
          if wallet.save
            present wallet, with: API::V2::Admin::Entities::Wallet
            status 201
          else
            body errors: wallet.errors.full_messages
            status 422
          end
        end

        desc 'Update wallet.' do
          success API::V2::Admin::Entities::Wallet
        end
        params do
          use :wallet_params
          requires :id,
                   type: { value: Integer, message: 'admin.wallet.non_integer_id' },
                   desc: -> { API::V2::Admin::Entities::Wallet.documentation[:id][:desc] }
          optional :blockchain_key,
                   values: { value: -> { ::Blockchain.pluck(:key) }, message: 'admin.wallet.blockchain_key_doesnt_exist' },
                   desc: -> { API::V2::Admin::Entities::Wallet.documentation[:blockchain_key][:desc] }
          optional :name,
                   desc: -> { API::V2::Admin::Entities::Wallet.documentation[:name][:desc] }
          optional :address,
                   desc: -> { API::V2::Admin::Entities::Wallet.documentation[:address][:desc] }
          optional :kind,
                   values: { value: ::Wallet.kind.values, message: 'admin.wallet.invalid_kind' },
                   desc: -> { API::V2::Admin::Entities::Wallet.documentation[:kind][:desc] }
          optional :gateway,
                   values: { value: -> { ::Wallet.gateways.map(&:to_s) }, message: 'admin.wallet.gateway_doesnt_exist' },
                   desc: -> { API::V2::Admin::Entities::Wallet.documentation[:gateway][:desc] }
          use :currency
        end
        post '/wallets/update' do
          authorize! :write, Wallet

          wallet = Wallet.find(params[:id])
          if wallet.update(declared(params, include_missing: false))
            present wallet, with: API::V2::Admin::Entities::Wallet
          else
            body errors: wallet.errors.full_messages
            status 422
          end
        end
      end
    end
  end
end
