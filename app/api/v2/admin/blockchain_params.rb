# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      module BlockchainParams
        extend ::Grape::API::Helpers

        params :create_blockchain_params do
          requires :key,
                   type: String,
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:key][:desc] }
          requires :name,
                   type: String,
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:name][:desc] }
          requires :client,
                   type: String,
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:client][:desc] }
          requires :server,
                   type: String,
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:server][:desc] }
          requires :height,
                   type: { value: Integer, message: 'admin.blockchain.non_integer_height' },
                   values: { value: -> (p){ p.try(:positive?) }, message: 'admin.blockchain.non_positive_height' },
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:height][:desc] }
          requires :explorer_transaction,
                   type: String,
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:explorer_transaction][:desc] }
          requires :explorer_address,
                   type: String,
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:explorer_address][:desc] }
          optional :status,
                   type: String,
                   values: { value: %w(active disabled), message: 'admin.blockchain.invalid_status' },
                   default: 'active',
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:status][:desc] }
          optional :min_confirmations,
                   type: { value: Integer, message: 'admin.blockchain.non_integer_min_confirmations' },
                   values: { value: -> (p){ p.try(:positive?) }, message: 'admin.blockchain.non_positive_min_confirmations' },
                   default: 6,
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:min_confirmations][:desc] }
          optional :step,
                   type: { value: Integer, message: 'admin.blockchain.non_integer_step' },
                   values: { value: -> (p){ p.try(:positive?) }, message: 'admin.blockchain.non_positive_step' },
                   default: 6,
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:step][:desc] }
        end

        params :update_blockchain_params do
          requires :id,
                   type: { value: Integer, message: 'admin.blockchain.non_integer_id' },
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:id][:desc] }
          optional :key,
                   type: String,
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:key][:desc] }
          optional :name,
                   type: String,
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:name][:desc] }
          optional :client,
                   type: String,
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:client][:desc] }
          optional :server,
                   type: String,
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:server][:desc] }
          optional :height,
                   type: { value: Integer, message: 'admin.blockchain.non_integer_height' },
                   values: { value: -> (p){ p.try(:positive?) }, message: 'admin.blockchain.non_positive_height' },
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:height][:desc] }
          optional :explorer_transaction,
                   type: String,
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:explorer_transaction][:desc] }
          optional :explorer_address,
                   type: String,
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:explorer_address][:desc] }
          optional :status,
                   type: String,
                   values: { value: %w(active disabled), message: 'admin.blockchain.invalid_status' },
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:status][:desc] }
          optional :min_confirmations,
                   type: { value: Integer, message: 'admin.blockchain.non_integer_min_confirmations' },
                   values: { value: -> (p){ p.try(:positive?) }, message: 'admin.blockchain.non_positive_min_confirmations' },
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:min_confirmations][:desc] }
          optional :step,
                   type: { value: Integer, message: 'admin.blockchain.non_integer_step' },
                   values: { value: -> (p){ p.try(:positive?) }, message: 'admin.blockchain.non_positive_step' },
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:step][:desc] }
        end
      end
    end
  end
end
