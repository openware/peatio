# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      class Blockchains < Grape::API
        helpers ::API::V2::Admin::BlockchainParams

        desc 'Get all blockchains, result is paginated.',
          is_array: true,
          success: API::V2::Admin::Entities::Blockchain
        params do
          optional :limit,
                   type: { value: Integer, message: 'admin.blockchain.non_integer_limit' },
                   values: { value: 1..1000, message: 'admin.blockchain.invalid_limit' },
                   default: 100,
                   desc: 'Limit the number of returned blockchains. Default to 100.'
          optional :page,
                   type: { value: Integer, message: 'admin.blockchain.non_integer_page' },
                   allow_blank: false,
                   default: 1,
                   desc: 'Specify the page of paginated results.'
          optional :ordering,
                   type: String,
                   values: { value: %w(asc desc), message: 'admin.blockchain.invalid_ordering' },
                   default: 'asc',
                   desc: 'If set, returned blockchains will be sorted in specific order, defaults to \'asc\'.'
          optional :order_by,
                   default: 'id',
                   type: String,
                   desc: 'Name of the field, which will be ordered by.'
        end
        get '/blockchains' do
          authorize! :read, Blockchain

          search = Blockchain.ransack()
          search.sorts = "#{params[:order_by]} #{params[:ordering]}"
          present paginate(search.result), with: API::V2::Admin::Entities::Blockchain
        end

        desc 'Get a blockchain.' do
          success API::V2::Admin::Entities::Blockchain
        end
        params do
          requires :id,
                   type: { value: Integer, message: 'admin.blockchain.non_integer_id' },
                   desc: -> { API::V2::Admin::Entities::Blockchain.documentation[:id][:desc] }
        end
        get '/blockchains/:id' do
          authorize! :read, Blockchain

          present Blockchain.find(params[:id]), with: API::V2::Admin::Entities::Blockchain
        end

        desc 'Create new blockchain.' do
          success API::V2::Admin::Entities::Blockchain
        end
        params do
          use :create_blockchain_params
        end
        post '/blockchains/new' do
          authorize! :create, Blockchain

          blockchain = Blockchain.new(declared(params))
          if blockchain.save
            present blockchain, with: API::V2::Admin::Entities::Blockchain
            status 201
          else
            body errors: blockchain.errors.full_messages
            status 422
          end
        end

        desc 'Update blockchain.' do
          success API::V2::Admin::Entities::Blockchain
        end
        params do
          use :update_blockchain_params
        end
        post '/blockchains/update' do
          authorize! :write, Blockchain

          blockchain = Blockchain.find(params[:id])
          if blockchain.update(declared(params, include_missing: false))
            present blockchain, with: API::V2::Admin::Entities::Blockchain
          else
            body errors: blockchain.errors.full_messages
            status 422
          end
        end
      end
    end
  end
end
