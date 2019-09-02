# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      class Withdraws < Grape::API
        helpers ::API::V2::Admin::Helpers

        COIN_ACTIONS = %w(process load approve fail)
        FIAT_ACTIONS = %w(accept reject)

        desc 'Get all withdraws, result is paginated.',
          is_array: true,
          success: API::V2::Admin::Entities::Deposit
        params do
          optional :state,
                   values: { value: -> { Withdraw::STATES.map(&:to_s) }, message: 'admin.withdraw.invalid_state' },
                   desc: -> { API::V2::Admin::Entities::Withdraw.documentation[:state][:desc] }
          optional :account,
                   type: Integer,
                   desc: -> { API::V2::Admin::Entities::Withdraw.documentation[:account][:desc] }
          optional :id,
                   type: Integer,
                   desc: -> { API::V2::Admin::Entities::Withdraw.documentation[:id][:desc] }
          optional :txid,
                   desc: -> { API::V2::Admin::Entities::Withdraw.documentation[:blockchain_txid][:desc] }
          optional :tid,
                   desc: -> { API::V2::Admin::Entities::Withdraw.documentation[:tid][:desc] }
          optional :confirmations,
                   type: Integer,
                   desc: -> { API::V2::Admin::Entities::Withdraw.documentation[:confirmations][:desc] }
          optional :rid,
                   desc: -> { API::V2::Admin::Entities::Withdraw.documentation[:rid][:desc] }
          use :uid
          use :currency
          use :currency_type
          use :date_picker
          use :pagination
          use :ordering
        end
        get '/withdraws' do
          authorize! :read, Withdraw

          ransack_params = Helpers::RansackBuilder.new(params)
                             .eq(:id, :txid, :rid, :tid)
                             .translate(state: :aasm_state, uid: :member_uid, account: :account_id, currency: :currency_id)
                             .with_daterange
                             .merge(type_eq: params[:type].present? ? "Withdraws::#{params[:type]}" : nil)
                             .build

          search = Withdraw.ransack(ransack_params)
          search.sorts = "#{params[:order_by]} #{params[:ordering]}"

          present paginate(search.result), with: API::V2::Admin::Entities::Withdraw
        end

        desc 'Update withdraw.',
          success: API::V2::Admin::Entities::Withdraw
        params do
          requires :id,
                   type: Integer,
                   desc: -> { API::V2::Admin::Entities::Withdraw.documentation[:id][:desc] }
          requires :action,
                   type: String,
                   values: { value: -> { COIN_ACTIONS | FIAT_ACTIONS }, message: 'admin.withdraw.invalid_action' },
                   desc: "Action to perform on withdraw. Valid actions for coin are #{COIN_ACTIONS}."\
                         "Valid actions for fiat are #{FIAT_ACTIONS}."
          optional :txid,
                 type: String,
                 desc: -> { API::V2::Admin::Entities::Withdraw.documentation[:blockchain_txid][:desc] }
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
            when 'process'
              success = withdraw.transaction do
                withdraw.accept!
                withdraw.process!
              end
              error!({ errors: ['admin.withdraw.cannot_process'] }, 422) unless success
            when 'load'
              success = withdraw.transaction do
                withdraw.update!(txid: params[:txid]) if params[:txid].present?
                withdraw.load!
              end
              error!({ errors: ['admin.withdraw.cannot_load'] }, 422) unless success
            when 'approve'
              success = withdraw.transaction do
                withdraw.update!(txid: params[:txid]) if params[:txid].present?
                withdraw.success!
              end
              error!({ errors: ['admin.withdraw.cannot_approve'] }, 422) unless success
            when 'fail'
              error!({ errors: ['admin.withdraw.cannot_fail'] }, 422) unless withdraw.fail!
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
