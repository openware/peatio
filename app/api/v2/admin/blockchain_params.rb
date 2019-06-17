# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      module BlockchainParams
        extend ::Grape::API::Helpers

        params :create_blockchain_params do
          requires :key,
                   type: { value: String, message: 'admin.blockchain.non_string_key'},
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:key][:desc] }
          requires :name,
                   type: { value: String, message: 'admin.blockchain.non_string_name'},
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:name][:desc] }
          requires :client,
                   type: { value: String, message: 'admin.blockchain.non_string_client'},
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:client][:desc] }
          requires :server,
                   type: { value: String, message: 'admin.blockchain.non_string_server'},
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:server][:desc] }
          requires :height,
                   type: { value: Integer, message: 'admin.blockchain.non_integer_height' },
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:height][:desc] }
          requires :explorer_transaction,
                   type: { value: String, message: 'admin.blockchain.non_string_explorer_transaction'},
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:explorer_transaction][:desc] }
          requires :explorer_address,
                   type: { value: String, message: 'admin.blockchain.non_string_explorer_address'},
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:explorer_address][:desc] }
          requires :status,
                   type: String,
                   values: { value: %w(active disabled), message: 'admin.blockchain.invalid_status' },
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:status][:desc] }
          requires :min_confirmations,
                   type: { value: Integer, message: 'admin.blockchain.non_integer_min_confirmations' },
                   values: { value: -> (p){ p > 0 }, message: 'admin.blockchain.invalid_min_confirmations' },
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:min_confirmations][:desc] }
          requires :step,
                   type: { value: Integer, message: 'admin.blockchain.non_integer_step' },
                   values: { value: -> (p){ p > 0 }, message: 'admin.blockchain.invalid_step' },
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:step][:desc] }
        end

        params :update_blockchain_params do
          requires :id,
                   type: { value: Integer, message: 'admin.blockchain.non_integer_id' },
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:id][:desc] }
          optional :key,
                   type: { value: String, message: 'admin.blockchain.non_string_key'},
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:key][:desc] }
          optional :name,
                   type: { value: String, message: 'admin.blockchain.non_string_name'},
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:name][:desc] }
          optional :client,
                   type: { value: String, message: 'admin.blockchain.non_string_client'},
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:client][:desc] }
          optional :server,
                   type: { value: String, message: 'admin.blockchain.non_string_server'},
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:server][:desc] }
          optional :height,
                   type: { value: Integer, message: 'admin.blockchain.non_integer_height' },
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:height][:desc] }
          optional :explorer_transaction,
                   type: { value: String, message: 'admin.blockchain.non_string_explorer_transaction'},
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:explorer_transaction][:desc] }
          optional :explorer_address,
                   type: { value: String, message: 'admin.blockchain.non_string_explorer_address'},
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:explorer_address][:desc] }
          optional :status,
                   type: String,
                   values: { value: %w(active disabled), message: 'admin.blockchain.invalid_status' },
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:status][:desc] }
          optional :min_confirmations,
                   type: { value: Integer, message: 'admin.blockchain.non_integer_min_confirmations' },
                   values: { value: -> (p){ p > 0 }, message: 'admin.blockchain.invalid_min_confirmations' },
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:min_confirmations][:desc] }
          optional :step,
                   type: { value: Integer, message: 'admin.blockchain.non_integer_step' },
                   values: { value: -> (p){ p > 0 }, message: 'admin.blockchain.invalid_step' },
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:step][:desc] }
        end
      end
    end
  end
end
