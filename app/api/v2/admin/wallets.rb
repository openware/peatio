# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      class Wallets < Grape::API
        helpers ::API::V2::Admin::WalletParams

        desc 'Get all wallets, result is paginated.',
          is_array: true,
          uccess: API::V2::Admin::Entities::Wallet
        params do
          optional :limit,
                   type: { value: Integer, message: 'admin.wallet.non_integer_limit' },
                   values: { value: 1..1000, message: 'admin.wallet.invalid_limit' },
                   default: 100,
                   desc: 'Limit the number of returned wallets. Default to 100.'
          optional :page,
                   type: { value: Integer, message: 'admin.wallet.non_integer_page' },
                   allow_blank: false,
                   default: 1,
                   desc: 'Specify the page of paginated results.'
          optional :ordering,
                   type: String,
                   values: { value: %w(asc desc), message: 'admin.wallet.invalid_ordering' },
                   default: 'asc',
                   desc: 'If set, returned wallets will be sorted in specific order, default to \'desc\'.'
          optional :order_by,
                   default: 'id',
                   type: String,
                   desc: 'Name of the field, which will be ordered by'
        end
        get '/wallets' do
          authorize! :read, Wallet

          search = Wallet.ransack()
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
          use :create_wallet_params
        end
        post '/wallets/new' do
          authorize! :create, Wallet

          wallet = Wallet.new(declared(params))
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
          use :update_wallet_params
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
