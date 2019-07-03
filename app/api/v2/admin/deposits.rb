# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      class Deposits < Grape::API
        helpers API::V2::Admin::DepositParams
        helpers API::V2::Admin::ParamsHelpers

        desc 'Get all deposits, result is paginated.',
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
            currency_id_eq: params[:currency],
            id_eq: params[:id],
            txid_eq: params[:txid],
            tid_eq: params[:tid],
            address_eq: params[:address],
            amount_gteq: params[:amount_from],
            amount_lt: params[:amount_to],
            type_eq: params[:type].present? ? "Deposits::#{params[:type]}" : nil,
            created_at_gteq: time_param(params[:created_at_from]),
            created_at_lt: time_param(params[:created_at_to]),
            updated_at_gteq: time_param(params[:updated_at_from]),
            updated_at_lt: time_param(params[:updated_at_to]),
            completed_at_gteq: time_param(params[:done_at_from]),
            completed_at_lt: time_param(params[:done_at_to]),
          }

          search = Deposit.ransack(ransack_params)
          search.sorts = "#{params[:order_by]} #{params[:ordering]}"

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
              error!({ errors: ['admin.deposit.cannot_accept'] }, 422) unless deposit.charge!
            when 'reject'
              error!({ errors: ['admin.deposit.cannot_reject'] }, 422) unless deposit.reject!
            else
              error!({ errors: ['admin.deposit.invalid_action'] }, 422)
            end
          else
            case params[:action]
            when 'accept'
              error!({ errors: ['admin.deposit.cannot_accept'] }, 422) unless deposit.accept!
            when 'collect'
              error!({ errors: ['admin.deposit.cannot_collect'] }, 422) unless deposit.may_dispatch? && deposit.collect!(false)
            when 'collect_fee'
              success =  deposit.may_dispatch? && deposit.currency.is_erc20? && deposit.collect!
              error!({ errors: ['admin.deposit.cannot_collect_fee'] }, 422) unless success
            else
              error!({ errors: ['admin.deposit.invalid_action'] }, 422)
            end
          end

          present deposit.reload with: API::V2::Admin::Entities::Deposit
        end
      end
    end
  end
end
