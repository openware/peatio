# encoding: UTF-8
# frozen_string_literal: true

module ManagementAPIv1
  class Wallets < Grape::API
    desc 'Returns all wallets' do
      @settings[:scope] = :read_wallets
      success ManagementAPIv1::Entities::Wallet
    end
    post '/wallets' do
      present Wallet.all, with: ManagementAPIv1::Entities::Wallet
      status 200
    end

    desc 'Returns wallet by id' do
      @settings[:scope] = :read_wallets
      success ManagementAPIv1::Entities::Wallet
    end
    params do
      requires :id, type: Integer, values: -> { Wallet.pluck(:id) }, desc: "Wallet id"
    end
    post '/wallet/get' do
      present Wallet.find_by!(id: params[:id]), with: ManagementAPIv1::Entities::Wallet
      status 200
    end

    desc 'Creates new wallet' do
      @settings[:scope] = :write_wallets
      success ManagementAPIv1::Entities::Wallet
    end
    params do
      requires :blockchain_key, type: String, values: -> { Blockchain.pluck(:key) },  desc: 'Blockachain key'
      requires :currency_id, type: String, values: -> { Currency.codes(bothcase: true) }, desc: 'Currency id'
      requires :gateway, type: String, values: -> { Wallet::GATEWAYS.map(&:to_s) }, desc: 'Wallet gateway'
      requires :name, type: String, desc: 'Wallet name'
      requires :address, type: String, desc: 'Wallet adress'
      requires :kind, type: String, values: -> { Wallet::KIND.map(&:to_s) }, desc: 'Wallet kind'
      requires :max_balance, type: BigDecimal, desc: 'Wallet max balance'
      requires :nsig, type: Integer, desc: 'Number of signatures'
      optional :parent, type: String, desc: 'Wallet parent'
      optional :status, type: String, default: 'active', desc: 'Wallet status active or disabled'
      optional :uri, type: String, desc: 'Wallet uri'
      optional :secret, type: String, desc: 'Wallet secret'
      optional :bitgo_test_net, type: Boolean, desc: 'Status of Bitgo testnet'
      optional :bitgo_wallet_id, type: String, desc: 'Bitgo wallet id'
      optional :bitgo_wallet_passphrase, type: String, desc: 'Bitgo Wallet Passphrase'
      optional :bitgo_rest_api_root, type: String, desc: 'Bitgo Rest Api Root'
      optional :bitgo_rest_api_access_token, type: String, desc: 'Bitgo Rest Api Access Token'
    end
    post '/wallet/new' do
      wallet = Wallet.new(params)
      if wallet.save
        present wallet, with: ManagementAPIv1::Entities::Wallet
        status 201
      else
        body errors: wallet.errors.full_messages
        status 422
      end
    end

    desc 'Updates exist wallet' do
      @settings[:scope] = :write_wallets
      success ManagementAPIv1::Entities::Wallet
    end
    params do
      requires :id, type: Integer, desc: "Wallet id"
      optional :blockchain_key, type: String, values: -> { Blockchain.pluck(:key) }, desc: 'Blockachain key'
      optional :currency_id, type: String, values: -> { Currency.codes(bothcase: true) }, desc: 'Currency id'
      optional :gateway, type: String, values: -> { Wallet::GATEWAYS.map(&:to_s) }, desc: 'Wallet gateway'
      optional :name, type: String, desc: 'Wallet name'
      optional :address, type: String, desc: 'Wallet adress'
      optional :kind, type: String, values: -> { Wallet::KIND.map(&:to_s) }, desc: 'Wallet kind'
      optional :max_balance, type: BigDecimal, desc: 'Wallet max balance'
      optional :nsig, type: Integer, desc: 'Number of signatures'
      optional :parent, type: String, desc: 'Wallet parent'
      optional :status, type: String, desc: 'Wallet status'
      optional :uri, type: String, desc: 'Wallet uri'
      optional :secret, type: String, desc: 'Wallet secret'
      optional :bitgo_test_net, type: Boolean, desc: 'Status of Bitgo testnet'
      optional :bitgo_wallet_id, type: String, desc: 'Bitgo wallet id'
      optional :bitgo_wallet_passphrase, type: String, desc: 'Bitgo Wallet Passphrase'
      optional :bitgo_rest_api_root, type: String, desc: 'Bitgo Rest Api Root'
      optional :bitgo_rest_api_access_token, type: String, desc: 'Bitgo Rest Api Access Token'
    end
    put '/wallet/update' do
      wallet = Wallet.find_by!(id: params[:id])
      if wallet.update(params)
        present wallet, with: ManagementAPIv1::Entities::Wallet
        status 200
      else
        body errors: wallet.errors.full_messages
        status 422
      end
    end
  end
end
