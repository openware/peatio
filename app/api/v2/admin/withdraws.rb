# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      class Withdraws < Grape::API
        helpers API::V2::Admin::WithdrawParams
        helpers API::V2::Admin::ParamsHelpers

        desc 'Get all withdraws, result is paginated.',
          is_array: true,
          success: API::V2::Admin::Entities::Deposit
        params do
          use :get_withdraws_params
        end
        get '/withdraws' do
          authorize! :read, Withdraw

          ransack_params = {
            aasm_state_eq: params[:state],
            member_id_eq: params[:member],
            account_id_eq: params[:account],
            currency_id_eq: params[:currency],
            id_eq: params[:id],
            txid_eq: params[:txid],
            rid_eq: params[:rid],
            tid_eq: params[:tid],
            amount_gteq: params[:amount_from],
            amount_lt: params[:amount_to],
            sum_gteq: params[:sum_from],
            sum_lt: params[:sum_to],
            type_eq: params[:type].present? ? "Withdraws::#{params[:type]}" : nil,
            created_at_gteq: time_param(params[:created_at_from]),
            created_at_lt: time_param(params[:created_at_to]),
            updated_at_gteq: time_param(params[:updated_at_from]),
            updated_at_lt: time_param(params[:updated_at_to]),
            completed_at_gteq: time_param(params[:done_at_from]),
            completed_at_lt: time_param(params[:done_at_to]),
          }

          search = Withdraw.ransack(ransack_params)
          search.sorts = "#{params[:order_by]} #{params[:ordering]}"

          present paginate(search.result), with: API::V2::Admin::Entities::Withdraw
        end

        desc 'Update withdraw.' do
          success API::V2::Admin::Entities::Withdraw
        end
        params do
          use :update_withdraw_params
        end
        post '/withdraws/update' do
          authorize! :write, Withdraw

          withdraw = Withdraw.find(params[:id])

          if withdraw.fiat?
            case params[:action]
            when 'accept'
              success = withdraw.transaction do
                withdraw.accept!
                withdraw.process!
                withdraw.dispatch!
                withdraw.success!
              end
              error!({ errors: ['admin.withdraw.cannot_accept'] }, 422) unless success
            when 'reject'
              error!({ errors: ['admin.withdraw.cannot_reject'] }, 422) unless withdraw.reject!
            else
              error!({ errors: ['admin.withdraw.invalid_action'] }, 422)
            end
          else
            case params[:action]
            when 'accept'
              error!({ errors: ['admin.withdraw.cannot_accept'] }, 422) unless withdraw.accept!
            when 'load'
              success = withdraw.transaction do
                withdraw.update!(txid: params[:txid])
                withdraw.load!
              end
              error!({ errors: ['admin.withdraw.cannot_load'] }, 422) unless success
            when 'reject'
              error!({ errors: ['admin.withdraw.cannot_reject'] }, 422) unless withdraw.reject!
            else
              error!({ errors: ['admin.withdraw.invalid_action'] }, 422)
            end
          end

          present withdraw.reload with: API::V2::Admin::Entities::Withdraw
        end
      end
    end
  end
end
