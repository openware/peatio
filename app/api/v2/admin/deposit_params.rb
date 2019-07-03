# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      module DepositParams
        extend ::Grape::API::Helpers

        COIN_ACTIONS = %w(accept collect collect_fee)
        FIAT_ACTIONS = %w(accept reject)

        params :get_deposits_params do
          optional :currency,
                   type: String,
                   values: { value: -> { Currency.enabled.codes(bothcase: true) }, message: 'admin.currency.doesnt_exist' },
                   desc: -> { API::V2::Admin::Entities::Deposit.documentation[:currency][:desc] }
          optional :state,
                   type: String,
                   values: { value: -> { Deposit::STATES.map(&:to_s) }, message: 'admin.deposit.invalid_state' },
                   desc: -> { API::V2::Admin::Entities::Deposit.documentation[:state][:desc] }
          optional :limit,
                   type: { value: Integer, message: 'admin.deposit.non_integer_limit' },
                   values: { value: 1..100, message: 'admin.deposit.invalid_limit' },
                   default: 100,
                   desc: "Number of deposits per page (defaults to 100, maximum is 100)."
          optional :page,
                   type: { value: Integer, message: 'admin.deposit.non_integer_page' },
                   values: { value: -> (p){ p.try(:positive?) }, message: 'admin.deposit.non_positive_page'},
                   default: 1,
                   desc: 'Page number (defaults to 1).'
          optional :member,
                   type: Integer,
                   desc: -> { API::V2::Admin::Entities::Deposit.documentation[:member][:desc] }
          optional :id,
                   type: Integer,
                   desc: -> { API::V2::Admin::Entities::Deposit.documentation[:id][:desc] }
          optional :txid,
                   type: String,
                   desc: -> { API::V2::Admin::Entities::Deposit.documentation[:blockchain_txid][:desc] }
          optional :address,
                   type: String,
                   desc: -> { API::V2::Admin::Entities::Deposit.documentation[:address][:desc] }
          optional :tid,
                   type: String,
                   desc: -> { API::V2::Admin::Entities::Deposit.documentation[:tid][:desc] }
          optional :type,
                   type: String,
                   values: { value: %w(fiat coin), message: 'admin.deposit.invalid_type' },
                   desc: -> { API::V2::Admin::Entities::Deposit.documentation[:type][:desc] }
          optional :amount_from,
                   type: { value: Integer, message: 'admin.deposit.non_integer_amount_from' },
                   allow_blank: { value: false, message: 'admin.deposit.empty_time_from' },
                   desc: 'If set, only withdraws with amount greater or equal then will be returned.'
          optional :amount_to,
                   type: { value: Integer, message: 'admin.deposit.non_integer_amount_to' },
                   allow_blank: { value: false, message: 'admin.deposit.empty_time_to' },
                   desc: 'If set, only withdraws with amount less then will be returned.'
          optional :updated_at_from,
                   type: { value: Integer, message: 'admin.deposit.non_integer_updated_at_from' },
                   allow_blank: { value: false, message: 'admin.deposit.empty_time_from' },
                   desc: "An integer represents the seconds elapsed since Unix epoch."\
                         "If set, only deposits updated after the time will be returned."
          optional :updated_at_to,
                   type: { value: Integer, message: 'admin.deposit.non_integer_updated_at_to' },
                   allow_blank: { value: false, message: 'admin.deposit.empty_time_to' },
                   desc: "An integer represents the seconds elapsed since Unix epoch."\
                         "If set, only deposits updated before the time will be returned."
          optional :created_at_from,
                   type: { value: Integer, message: 'admin.deposit.non_integer_created_at_from' },
                   allow_blank: { value: false, message: 'admin.deposit.empty_time_from' },
                   desc: "An integer represents the seconds elapsed since Unix epoch."\
                         "If set, only deposits created after the time will be returned."
          optional :created_at_to,
                   type: { value: Integer, message: 'admin.deposit.non_integer_created_at_to' },
                   allow_blank: { value: false, message: 'admin.deposit.empty_time_to' },
                   desc: "An integer represents the seconds elapsed since Unix epoch."\
                         "If set, only deposits created before the time will be returned."
          optional :done_at_from,
                   type: { value: Integer, message: 'admin.deposit.non_integer_done_at_from' },
                   allow_blank: { value: false, message: 'admin.deposit.empty_time_from' },
                   desc: "An integer represents the seconds elapsed since Unix epoch."\
                         "If set, only deposits done after the time will be returned."
          optional :done_at_to,
                   type: { value: Integer, message: 'admin.deposit.non_integer_done_at_to' },
                   allow_blank: { value: false, message: 'admin.deposit.empty_time_to' },
                   desc: "An integer represents the seconds elapsed since Unix epoch."\
                         "If set, only deposits done before the time will be returned."
          optional :ordering,
                   type: String,
                   values: { value: %w(asc desc), message: 'admin.deposit.invalid_ordering' },
                   default: 'asc',
                   desc: 'If set, returned deposits will be sorted in specific order, defaults to \'asc\'.'
          optional :order_by,
                   default: 'id',
                   type: String,
                   desc: 'Name of the field to order deposits by.'
        end

        params :update_deposit_params do
          requires :id,
                   type: Integer,
                   desc: -> { API::V2::Admin::Entities::Deposit.documentation[:id][:desc] }
          requires :action,
                   type: String,
                   values: { value: -> { COIN_ACTIONS | FIAT_ACTIONS }, message: 'admin.deposit.invalid_action' },
                   desc: "Action to perform on deposit. Valid actions for coin are #{COIN_ACTIONS}."\
                         "Valid actions for fiat are #{FIAT_ACTIONS}."
        end
      end
    end
  end
end
