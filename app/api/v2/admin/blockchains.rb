# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      class Blockchains < Grape::API
        helpers ::API::V2::Admin::NamedParams

        desc 'Get all blockchains, results is paginated.',
          is_array: true,
          success: API::V2::Admin::Entities::Blockchain
        params do
          use :paginate_param
        end
        get '/blockchains' do
          authorize! :read, Blockchain

          present paginate(Blockchain.all), with: API::V2::Admin::Entities::Blockchain
        end

        desc 'Get a blockchain' do
          success API::V2::Admin::Entities::Blockchain
        end
        params do
          requires :id,
                   type: Integer,
                   desc: -> { API::V2::Admin::Blockchain.documentation[:id] }
        end
        get '/blockchains/:id' do
          authorize! :read, Blockchain

          present Blockchain.find(params[:id]), with: API::V2::Admin::Entities::Blockchain
        end

        desc 'Creates new blockchain.' do
          success API::V2::Admin::Entities::Blockchain
        end
        params do
          use :blockchains_param
        end
        post '/blockchains/new' do
          authorize! :create, Blockchain

          data = declared(params)
          blockchain = Blockchain.new(data)
          if blockchain.save
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
