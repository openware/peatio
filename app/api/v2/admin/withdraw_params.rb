# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      module WithdrawParams
        extend ::Grape::API::Helpers

        COIN_ACTIONS = %w(process load reject)
        FIAT_ACTIONS = %w(accept reject)

        params :get_withdraws_params do
          optional :currency,
                   type: String,
                   values: { value: -> { Currency.enabled.codes(bothcase: true) }, message: 'admin.currency.doesnt_exist' },
                   desc: -> { API::V2::Admin::Entities::Withdraw.documentation[:currency][:desc] }
          optional :state,
                   type: String,
                   values: { value: -> { Withdraw::STATES.map(&:to_s) }, message: 'admin.withdraw.invalid_state' },
                   desc: -> { API::V2::Admin::Entities::Withdraw.documentation[:state][:desc] }
          optional :limit,
                   type: { value: Integer, message: 'admin.withdraw.non_integer_limit' },
                   values: { value: 1..100, message: 'admin.withdraw.invalid_limit' },
                   default: 100,
                   desc: 'Number of withdraws per page (defaults to 100, maximum is 100).'
          optional :page,
                   type: { value: Integer, message: 'admin.withdraw.non_integer_page' },
                   values: { value: -> (p){ p.try(:positive?) }, message: 'admin.withdraw.non_positive_page'},
                   default: 1,
                   desc: 'Page number (defaults to 1).'
          optional :member,
                   type: Integer,
                   desc: -> { API::V2::Admin::Entities::Withdraw.documentation[:member][:desc] }
          optional :account,
                   type: Integer,
                   desc: -> { API::V2::Admin::Entities::Withdraw.documentation[:account][:desc] }
          optional :id,
                   type: Integer,
                   desc: -> { API::V2::Admin::Entities::Withdraw.documentation[:id][:desc] }
          optional :txid,
                   type: String,
                   desc: -> { API::V2::Admin::Entities::Withdraw.documentation[:blockchain_txid][:desc] }
          optional :tid,
                   type: String,
                   desc: -> { API::V2::Admin::Entities::Withdraw.documentation[:tid][:desc] }
          optional :confirmations,
                   type: Integer,
                   desc: -> { API::V2::Admin::Entities::Withdraw.documentation[:confirmations][:desc] }
          optional :rid,
                   type: String,
                   desc: -> { API::V2::Admin::Entities::Withdraw.documentation[:rid][:desc] }
          optional :type,
                   type: String,
                   values: { value: %w(fiat coin), message: 'admin.withdraw.invalid_type' },
                   desc: -> { API::V2::Admin::Entities::Withdraw.documentation[:type][:desc] }
          optional :amount_from,
                   type: { value: Integer, message: 'admin.withdraw.non_integer_amount_from' },
                   allow_blank: { value: false, message: 'admin.withdraw.empty_amount_from' },
                   desc: 'If set, only withdraws with amount greater or equal then will be returned.'
          optional :amount_to,
                   type: { value: Integer, message: 'admin.withdraw.non_integer_amount_to' },
                   allow_blank: { value: false, message: 'admin.withdraw.empty_amount_to' },
                   desc: 'If set, only withdraws with amount less then will be returned.'
          optional :sum_from,
                   type: { value: Integer, message: 'admin.withdraw.non_integer_sum_from' },
                   allow_blank: { value: false, message: 'admin.withdraw.empty_sum_from' },
                   desc: 'If set, only withdraws with sum greater or equal then will be returned.'
          optional :sum_to,
                   type: { value: Integer, message: 'admin.withdraw.non_integer_sum_to' },
                   allow_blank: { value: false, message: 'admin.withdraw.empty_sum_to' },
                   desc: 'If set, only withdraws with sum less then will be returned.'
          optional :updated_at_from,
                   type: { value: Integer, message: 'admin.withdraw.non_integer_updated_at_from' },
                   allow_blank: { value: false, message: 'admin.withdraw.empty_time_from' },
                   desc: "An integer represents the seconds elapsed since Unix epoch."\
                         "If set, only withdraws updated after the time will be returned."
          optional :updated_at_to,
                   type: { value: Integer, message: 'admin.withdraw.non_integer_updated_at_to' },
                   allow_blank: { value: false, message: 'admin.withdraw.empty_time_to' },
                   desc: "An integer represents the seconds elapsed since Unix epoch."\
                         "If set, only withdraws updated before the time will be returned."
          optional :created_at_from,
                   type: { value: Integer, message: 'admin.withdraw.non_integer_created_at_from' },
                   allow_blank: { value: false, message: 'admin.withdraw.empty_time_from' },
                   desc: "An integer represents the seconds elapsed since Unix epoch."\
                         "If set, only withdraws created after the time will be returned."
          optional :created_at_to,
                   type: { value: Integer, message: 'admin.withdraw.non_integer_created_at_to' },
                   allow_blank: { value: false, message: 'admin.withdraw.empty_time_to' },
                   desc: "An integer represents the seconds elapsed since Unix epoch."\
                         "If set, only withdraws created before the time will be returned."
          optional :done_at_from,
                   type: { value: Integer, message: 'admin.withdraw.non_integer_done_at_from' },
                   allow_blank: { value: false, message: 'admin.withdraw.empty_time_from' },
                   desc: "An integer represents the seconds elapsed since Unix epoch."\
                         "If set, only withdraws done after the time will be returned."
          optional :done_at_to,
                   type: { value: Integer, message: 'admin.withdraw.non_integer_done_at_to' },
                   allow_blank: { value: false, message: 'admin.withdraw.empty_time_to' },
                   desc: "An integer represents the seconds elapsed since Unix epoch."\
                         "If set, only withdraws done before the time will be returned."
          optional :ordering,
                   type: String,
                   values: { value: %w(asc desc), message: 'admin.withdraw.invalid_ordering' },
                   default: 'asc',
                   desc: 'If set, returned withdraws will be sorted in specific order, defaults to \'asc\'.'
          optional :order_by,
                   default: 'id',
                   type: String,
                   desc: 'Name of the field to order withdraws by.'
        end

        params :update_withdraw_params do
          requires :id,
                   type: Integer,
                   desc: -> { API::V2::Admin::Entities::Withdraw.documentation[:id][:desc] }
          requires :action,
                   type: String,
                   values: { value: -> { COIN_ACTIONS | FIAT_ACTIONS }, message: 'admin.withdraw.invalid_action' },
                   desc: "Action to perform on withdraw. Valid actions for coin are #{COIN_ACTIONS}."\
                         "Valid actions for fiat are #{FIAT_ACTIONS}."
          given action: ->(action) { action == 'load' } do
            requires :txid,
                   type: String,
                   desc: -> { API::V2::Admin::Entities::Withdraw.documentation[:blockchain_txid][:desc] }
          end
        end
      end
    end
  end
end
