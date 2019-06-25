# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      class Blockchains < Grape::API
        helpers ::API::V2::Admin::BlockchainParams

        desc 'Get all blockchains, results is paginated.',
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
          optional :order_by,
                   type: String,
                   values: { value: %w(asc desc), message: 'admin.blockchain.invalid_order_by' },
                   default: 'desc',
                   desc: "If set, returned blockchains will be sorted in specific order, default to 'desc'."
          optional :sort_field,
                   type: String,
                   desc: 'Name of the field, which will be ordered by'
        end
        get '/blockchains' do
          authorize! :read, Blockchain

          search = Blockchain.ransack()
          search.sorts = "#{params[:sort_field]} #{params[:order_by]}" if params[:sort_field].present?
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

          data = declared(params)
          blockchain = Blockchain.new(data)
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
          if blockchain.update(params)
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
