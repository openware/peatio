# encoding: UTF-8
# frozen_string_literal: true

module ManagementAPIv1
  class Wallets < Grape::API

    desc 'Return wallet by id' do
      @settings[:scope] = :read_wallets
      success ManagementAPIv1::Entities::Wallet
    end
    params do
      requires :id, type: Integer, desc: "Wallet id"
    end
    post '/wallet/get' do
      present Wallet.find(params[:id]), with: ManagementAPIv1::Entities::Wallet
      status 200
    end

    desc 'Return all wallets' do
      @settings[:scope] = :read_wallets
      success ManagementAPIv1::Entities::Wallet
    end
    post '/wallets' do
      present Wallet.all, with: ManagementAPIv1::Entities::Wallet
      status 200
    end

    desc 'Update wallet' do
      @settings[:scope] = :write_wallets
      success ManagementAPIv1::Entities::Wallet
    end
    params do
      requires :id, type: Integer, desc: "Wallet id"
      optional :currency_id, type: String, desc: 'Currency id'
      optional :blockchain_key, type: String, desc: 'Blockachain key'
      optional :name, type: String, desc: 'Wallet name'
      optional :address, type: String, desc: 'Wallet adress'
      optional :max_balance, type: BigDecimal, desc: 'Wallet max balance'
      optional :kind, type: String, desc: 'Wallet kind'
      optional :nsig, type: Integer, desc: 'Number of signatures'
      optional :parent, type: String, desc: 'Wallet parent'
      optional :status, type: String, desc: 'Wallet status'
      optional :gateway, type: String, desc: 'Wallet gateway'
      optional :uri, type: String, desc: 'Wallet uri'
      optional :secret, type: String, desc: 'Wallet secret'
      optional :bitgo_test_net, type: Boolean, desc: 'Status of Bitgo testnet'
      optional :bitgo_wallet_id, type: String, desc: 'Bitgo wallet id'
      optional :bitgo_wallet_passphrase, type: String, desc: 'Bitgo Wallet Passphrase'
      optional :bitgo_rest_api_root, type: String, desc: 'Bitgo Rest Api Root'
      optional :bitgo_rest_api_access_token, type: String, desc: 'Bitgo Rest Api Access Token'
    end
    put '/wallet/update' do
      wallet = Wallet.find(params[:id])
      if wallet.update(params)
        present wallet, with: ManagementAPIv1::Entities::Wallet
        status 200
      else
        body errors: wallet.errors.full_messages
        status 422
      end
    end

    desc 'Create wallet' do
      @settings[:scope] = :write_wallets
      success ManagementAPIv1::Entities::Wallet
    end
    params do
      requires :currency_id, type: String, desc: 'Currency id'
      requires :blockchain_key, type: String, desc: 'Blockachain key'
      requires :name, type: String, desc: 'Wallet name'
      requires :address, type: String, desc: 'Wallet adress'
      requires :max_balance, type: BigDecimal, desc: 'Wallet max balance'
      requires :kind, type: String, desc: 'Wallet kind'
      requires :nsig, type: Integer, desc: 'Number of signatures'
      requires :gateway, type: String, desc: 'Wallet gateway'
      optional :status, type: String, default: 'active', desc: 'Wallet status'
      optional :id, type: Integer, desc: "Wallet id"
      optional :parent, type: String, desc: 'Wallet parent'
      optional :uri, type: String, desc: 'Wallet uri'
      optional :secret, type: String, desc: 'Wallet secret'
      optional :bitgo_test_net, type: Boolean, desc: 'Status of Bitgo testnet'
      optional :bitgo_wallet_id, type: String, desc: 'Bitgo wallet id'
      optional :bitgo_wallet_passphrase, type: String, desc: 'Bitgo Wallet Passphrase'
      optional :bitgo_rest_api_root, type: String, desc: 'Bitgo Rest Api Root'
      optional :bitgo_rest_api_access_token, type: String, desc: 'Bitgo Rest Api Access Token'   
    end
    post '/wallet/new' do
      wallet = Wallet.new
      wallet.assign_attributes(params)
      if wallet.save
        present wallet, with: ManagementAPIv1::Entities::Wallet
        status 201
      else
        body errors: wallet.errors.full_messages
        status 422
      end
    end
  end
end
