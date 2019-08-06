# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      class Deposits < Grape::API
        helpers ::API::V2::Admin::Helpers
        helpers do
          COIN_ACTIONS = %w(accept collect collect_fee)
          FIAT_ACTIONS = %w(accept reject)
        end

        desc 'Get all deposits, result is paginated.',
          is_array: true,
          success: API::V2::Admin::Entities::Deposit
        params do
          optional :state,
                   values: { value: -> { Deposit::STATES.map(&:to_s) }, message: 'admin.deposit.invalid_state' },
                   desc: -> { API::V2::Admin::Entities::Deposit.documentation[:state][:desc] }
          optional :id,
                   type: Integer,
                   desc: -> { API::V2::Admin::Entities::Deposit.documentation[:id][:desc] }
          optional :txid,
                   desc: -> { API::V2::Admin::Entities::Deposit.documentation[:blockchain_txid][:desc] }
          optional :address,
                   desc: -> { API::V2::Admin::Entities::Deposit.documentation[:address][:desc] }
          optional :tid,
                   desc: -> { API::V2::Admin::Entities::Deposit.documentation[:tid][:desc] }
          use :uid
          use :currency
          use :currency_type
          use :date_picker
          use :pagination
          use :ordering
        end
        get '/deposits' do
          authorize! :read, Deposit

          ransack_params = Helpers::RansackBuilder.new(params)
                             .eq(:id, :txid, :tid, :address)
                             .map(aasm_state: :state, member_uid: :uid, currency_id: :currency)
                             .build(type_eq: params[:type].present? ? "Deposits::#{params[:type]}" : nil)

          search = Deposit.ransack(ransack_params)
          search.sorts = "#{params[:order_by]} #{params[:ordering]}"

          present paginate(search.result), with: API::V2::Admin::Entities::Deposit
        end

        # desc 'Update deposit.' do
        #   success API::V2::Admin::Entities::Deposit
        # end
        # params do
        #   requires :id,
        #            type: Integer,
        #            desc: -> { API::V2::Admin::Entities::Deposit.documentation[:id][:desc] }
        #   requires :action,
        #            values: { value: -> { COIN_ACTIONS | FIAT_ACTIONS }, message: 'admin.deposit.invalid_action' },
        #            desc: "Action to perform on deposit. Valid actions for coin are #{COIN_ACTIONS}."\
        #                  "Valid actions for fiat are #{FIAT_ACTIONS}."
        # end
        # post '/deposits/update' do
        #   authorize! :write, Deposit

        #   deposit = Deposit.find(params[:id])

        #   if deposit.fiat?
        #     case params[:action]
        #     when 'accept'
        #       error!({ errors: ['admin.deposit.cannot_accept'] }, 422) unless deposit.charge!
        #     when 'reject'
        #       error!({ errors: ['admin.deposit.cannot_reject'] }, 422) unless deposit.reject!
        #     else
        #       error!({ errors: ['admin.deposit.invalid_action'] }, 422)
        #     end
        #   else
        #     case params[:action]
        #     when 'accept'
        #       error!({ errors: ['admin.deposit.cannot_accept'] }, 422) unless deposit.accept!
        #     when 'collect'
        #       error!({ errors: ['admin.deposit.cannot_collect'] }, 422) unless deposit.may_dispatch? && deposit.collect!(false)
        #     when 'collect_fee'
        #       success =  deposit.may_dispatch? && deposit.currency.is_erc20? && deposit.collect!
        #       error!({ errors: ['admin.deposit.cannot_collect_fee'] }, 422) unless success
        #     else
        #       error!({ errors: ['admin.deposit.invalid_action'] }, 422)
        #     end
        #   end

        #   present deposit.reload with: API::V2::Admin::Entities::Deposit
        # end
      end
    end
  end
end
