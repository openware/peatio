# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      class Withdraws < Grape::API
        helpers ::API::V2::Admin::Helpers
        helpers do
          COIN_ACTIONS = %w(process load reject)
          FIAT_ACTIONS = %w(accept reject)
        end

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
          use :date_picker, keys: %w[updated_at created_at completed_at]
          use :pagination
          use :ordering
        end
        get '/withdraws' do
          authorize! :read, Withdraw

          ransack_params = Helpers::RansackBuilder.new(params)
                             .eq(:id, :txid, :rid, :tid)
                             .map(aasm_state: :state, member_uid: :uid, account_id: :account, currencie_id: :currency)
                             .build(type_eq: params[:type].present? ? "Withdraws::#{params[:type]}" : nil)

          search = Withdraw.ransack(ransack_params)
          search.sorts = "#{params[:order_by]} #{params[:ordering]}"

          present paginate(search.result), with: API::V2::Admin::Entities::Withdraw
        end

        # desc 'Update withdraw.' do
        #   success API::V2::Admin::Entities::Withdraw
        # end
        # params do
        #   requires :id,
        #            type: Integer,
        #            desc: -> { API::V2::Admin::Entities::Withdraw.documentation[:id][:desc] }
        #   requires :action,
        #            values: { value: -> { WITHDRAW_COIN_ACTIONS | WITHDRAW_FIAT_ACTIONS }, message: 'admin.withdraw.invalid_action' },
        #            desc: "Action to perform on withdraw. Valid actions for coin are #{COIN_ACTIONS}."\
        #                  "Valid actions for fiat are #{FIAT_ACTIONS}."
        #   given action: ->(action) { action == 'load' } do
        #     requires :txid,
        #            desc: -> { API::V2::Admin::Entities::Withdraw.documentation[:blockchain_txid][:desc] }
        #   end
        # end
        # post '/withdraws/update' do
        #   authorize! :write, Withdraw

        #   withdraw = Withdraw.find(params[:id])

        #   if withdraw.fiat?
        #     case params[:action]
        #     when 'accept'
        #       success = withdraw.transaction do
        #         withdraw.accept!
        #         withdraw.process!
        #         withdraw.dispatch!
        #         withdraw.success!
        #       end
        #       error!({ errors: ['admin.withdraw.cannot_accept'] }, 422) unless success
        #     when 'reject'
        #       error!({ errors: ['admin.withdraw.cannot_reject'] }, 422) unless withdraw.reject!
        #     else
        #       error!({ errors: ['admin.withdraw.invalid_action'] }, 422)
        #     end
        #   else
        #     case params[:action]
        #     when 'accept'
        #       error!({ errors: ['admin.withdraw.cannot_accept'] }, 422) unless withdraw.accept!
        #     when 'load'
        #       success = withdraw.transaction do
        #         withdraw.update!(txid: params[:txid])
        #         withdraw.load!
        #       end
        #       error!({ errors: ['admin.withdraw.cannot_load'] }, 422) unless success
        #     when 'reject'
        #       error!({ errors: ['admin.withdraw.cannot_reject'] }, 422) unless withdraw.reject!
        #     else
        #       error!({ errors: ['admin.withdraw.invalid_action'] }, 422)
        #     end
        #   end

        #   present withdraw.reload with: API::V2::Admin::Entities::Withdraw
        # end
      end
    end
  end
end
