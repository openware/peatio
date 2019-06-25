# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      module WalletParams
        extend ::Grape::API::Helpers

        params :create_wallet_params do
          requires :blockchain_key,
                   type: String,
                   values: { value: -> { ::Blockchain.pluck(:key) }, message: 'admin.wallet.blockchain_key_doesnt_exist' },
                   desc: -> { V2::Admin::Entities::Wallet.documentation[:blockchain_key][:desc] }
          requires :name,
                   type: String,
                   desc: -> { V2::Admin::Entities::Wallet.documentation[:name][:desc] }
          requires :address,
                   type: String,
                   desc: -> { V2::Admin::Entities::Wallet.documentation[:address][:desc] }
          requires :currency_id,
                   type: String,
                   values: { value: -> { ::Currency.ids }, message: 'admin.wallet.currency_id_doesnt_exist' },
                   desc: -> { V2::Admin::Entities::Wallet.documentation[:currency_id][:desc] }
          requires :kind,
                   type: String,
                   values: { value: ::Wallet.kind.values, message: 'admin.wallet.invalid_kind' },
                   desc: -> { V2::Admin::Entities::Wallet.documentation[:kind][:desc] }
          requires :gateway,
                   type: String,
                   values: { value: -> { ::Blockchain.pluck(:client) }, message: 'admin.wallet.gateway_doesnt_exist' },
                   desc: -> { V2::Admin::Entities::Wallet.documentation[:gateway][:desc] }
          requires :settings,
                   type: { value: JSON, message: 'admin.wallet.non_json_settings' },
                   desc: -> { V2::Admin::Entities::Wallet.documentation[:settings][:desc] }
          optional :nsig,
                   type: { value: Integer, message: 'admin.wallet.non_integer_nsig' },
                   default: 1,
                   desc: -> { V2::Admin::Entities::Wallet.documentation[:nsig][:desc] }
          optional :max_balance,
                   type: { value: BigDecimal, message: 'admin.blockchain.non_decimal_max_balance' },
                   default: 0.0,
                   values: { value: -> (p){ p >= 0 }, message: 'admin.wallet.invalid_max_balance' },
                   desc: -> { V2::Admin::Entities::Wallet.documentation[:max_balance][:desc] }
          optional :parent,
                   type: { value: String, message: 'admin.wallet.non_string_parent'},
                   desc: -> { V2::Admin::Entities::Wallet.documentation[:parent][:desc] }
          optional :status,
                   type: String,
                   values: { value: %w(active disabled), message: 'admin.wallet.invalid_status' },
                   default: 'active',
                   desc: -> { V2::Admin::Entities::Wallet.documentation[:status][:desc] }
        end

        params :update_wallet_params do
          requires :id,
                   type: { value: Integer, message: 'admin.wallet.non_integer_id' },
                   desc: -> { API::V2::Admin::Entities::Wallet.documentation[:id][:desc] }
          optional :blockchain_key,
                   type: String,
                   values: { value: -> { ::Blockchain.pluck(:key) }, message: 'admin.wallet.blockchain_key_doesnt_exist' },
                   desc: -> { V2::Admin::Entities::Wallet.documentation[:blockchain_key][:desc] }
          optional :name,
                   type: String,
                   desc: -> { V2::Admin::Entities::Wallet.documentation[:name][:desc] }
          optional :address,
                   type: String,
                   desc: -> { V2::Admin::Entities::Wallet.documentation[:address][:desc] }
          optional :kind,
                   type: String,
                   values: { value: ::Wallet.kind.values, message: 'admin.wallet.invalid_kind' },
                   desc: -> { V2::Admin::Entities::Wallet.documentation[:kind][:desc] }
          optional :nsig,
                   type: { value: Integer, message: 'admin.wallet.non_integer_nsig' },
                   desc: -> { V2::Admin::Entities::Wallet.documentation[:nsig][:desc] }
          optional :gateway,
                   type: String,
                   values: { value: -> { ::Blockchain.pluck(:client) }, message: 'admin.wallet.gateway_doesnt_exist' },
                   desc: -> { V2::Admin::Entities::Wallet.documentation[:gateway][:desc] }
          optional :max_balance,
                   type: { value: BigDecimal, message: 'admin.blockchain.non_decimal_max_balance' },
                   values: { value: -> (p){ p >= 0 }, message: 'admin.wallet.invalid_max_balance' },
                   desc: -> { V2::Admin::Entities::Wallet.documentation[:max_balance][:desc] }
          optional :parent,
                   type: { value: String, message: 'admin.wallet.non_string_parent'},
                   desc: -> { V2::Admin::Entities::Wallet.documentation[:parent][:desc] }
          optional :status,
                   type: String,
                   values: { value: %w(active disabled), message: 'admin.wallet.invalid_status' },
                   desc: -> { V2::Admin::Entities::Wallet.documentation[:status][:desc] }
          optional :currency_id,
                   type: String,
                   values: { value: -> { ::Currency.ids }, message: 'admin.wallet.currency_id_doesnt_exist' },
                   desc: -> { V2::Admin::Entities::Wallet.documentation[:currency_id][:desc] }
          optional :settings,
                   type: { value: String, message: 'admin.wallet.non_string_settings' },
                   desc: -> { V2::Admin::Entities::Wallet.documentation[:settings][:desc] }
        end
      end
    end
  end
end
