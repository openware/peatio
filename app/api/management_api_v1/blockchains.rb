# encoding: UTF-8
# frozen_string_literal: true

module ManagementAPIv1
  class Blockchains < Grape::API
    desc 'Returns all blockchains.' do
      @settings[:scope] = :read_blockchains
      success ManagementAPIv1::Entities::Blockchain
    end
    post '/blockchains' do
      present Blockchain.all, with: ManagementAPIv1::Entities::Blockchain
      status 200
    end

    desc 'Return blockchain by key.' do
      @settings[:scope] = :read_blockchains
      success ManagementAPIv1::Entities::Blockchain
    end
    params do
      requires :key, type: String, desc: 'Blockchain key'
    end
    post 'blockchains/get' do
      present Blockchain.find_by(key: params[:key]), with: ManagementAPIv1::Entities::Blockchain
      status 200
    end

    desc 'Create new blockchain' do
      @settings[:scope] = :write_blockchains
      success ManagementAPIv1::Entities::Blockchain
    end
    params do
      requires :key, type: String, desc: 'Blockchain key'
      requires :name, type: String, desc: 'Blockchain name'
      requires :client, type: String, desc: 'Blockchain client'
      requires :server, type: String, desc: 'Blockchain server'
      requires :height, type: Integer, desc: 'Blockchain height'
      requires :explorer_address, type: String, desc: 'Blockchain explorer address'
      requires :explorer_transaction, type: String, desc: 'Blockchain explorer transaction'
      optional :min_confirmations, type: Integer, default: 6, desc: 'Minimum confirmations from network'
      optional :status, type: String, default: 'active', desc: 'Blockchain status'
    end
    post 'blockchains/new' do
      blockchain = Blockchain.new
      blockchain.assign_attributes(params)
      if blockchain.save
        present blockchain, with: ManagementAPIv1::Entities::Blockchain
        status 201
      else
        body errors: blockchain.errors.full_messages
        status 422
      end
    end

    desc 'Update exist blockchain' do
      @settings[:scope] = :write_blockchains
      success ManagementAPIv1::Entities::Blockchain
    end
    params do
      requires :key, type: String, desc: 'Blockchain key'
      optional :name, type: String, desc: 'Blockchain name'
      optional :client, type: String, desc: 'Blockchain client'
      optional :server, type: String, desc: 'Blockchain server'
      optional :height, type: Integer, desc: 'Blockchain height'
      optional :explorer_address, type: String, desc: 'Blockchain explorer address'
      optional :explorer_transaction, type: String, desc: 'Blockchain explorer transaction'
      optional :min_confirmations, type: Integer, default: 6, desc: 'Minimum confirmations from network'
      optional :status, type: String, default: 'active', desc: 'Blockchain status'
    end
    put 'blockchains/update' do
      blockchain = Blockchain.find_by(key: params[:key])
      if blockchain.update(params)
        present blockchain, with: ManagementAPIv1::Entities::Blockchain
        status 200
      else
        body errors: blockchain.errors.full_messages
        status 422
      end
    end
  end
end
