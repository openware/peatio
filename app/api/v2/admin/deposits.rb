# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      class Deposits < Grape::API
        helpers DepositParams
        helpers ParamsHelpers

        desc 'Get all deposits, results is paginated.',
          is_array: true,
          success: API::V2::Admin::Entities::Deposit
        params do
          use :get_deposits_params
        end
        get '/deposits' do
          authorize! :read, Deposit

          ransack_params = {
            aasm_state_eq: params[:state],
            member_id_eq: params[:member],
            id_eq: params[:id],
            txid_eq: params[:txid],
            address_eq: params[:address],
            amount_gteq: params[:amount_from],
            amount_lt: params[:amount_to],
            type_eq: params[:type].present? ? "Deposits::#{params[:type]}" : nil,
            created_at_gteq: time_param(params[:created_at_from]),
            created_at_lt: time_param(params[:created_at_to]),
            updated_at_gteq: time_param(params[:updated_at_from]),
            updated_at_lt: time_param(params[:updated_at_to]),
            completed_at_gteq: time_param(params[:completed_at_from]),
            completed_at_lt: time_param(params[:completed_at_to]),
          }

          search = Deposit.ransack(ransack_params)
          search.sorts = "#{params[:order_by]} #{params[:ordering]}" if params[:order_by].present?

          present paginate(search.result), with: API::V2::Admin::Entities::Deposit
        end

        desc 'Update deposit.' do
          success API::V2::Admin::Entities::Deposit
        end
        params do
          use :update_deposit_params
        end
        post '/deposits/update' do
          authorize! :write, Deposit

          deposit = Deposit.find(params[:id])

          if deposit.fiat?
            case params[:action]
            when 'accept'
              deposit.accept!
            when 'reject'
              deposit.reject!
            else
              body errors: [ 'admin.deposit.invalid_action' ]
              status 422
              return
            end
          else
            case params[:action]
            when 'accept'
              deposit.accept! if deposit.may_accept?
            when 'collect'
              deposit.collect!(false) if deposit.may_dispatch?
            when 'collect_fee'
              deposit.collect!
            else
              body errors: [ 'admin.deposit.invalid_action' ]
              status 422
              return
            end
          end

          present deposit.reload with: API::V2::Admin::Entities::Deposit
        end
      end
    end
  end
end
