# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      module OperationParams
        extend ::Grape::API::Helpers

        params :get_operations_params do
          optional :currency,
                   type: String,
                   values: -> { Currency.codes(bothcase: true) },
                   desc: 'The currency for operations filtering.'
          optional :uid,
                   type: String,
                   values:  { value: -> (v) {Member.find_by(uid: v) }, message: 'admin.user.doesnt_exist' },
                   desc: -> { API::V2::Entities::Member.documentation[:uid][:desc] }
          optional :reference_type,
                   type: String,
                   desc: 'The reference type for which operation was created.'
          optional :rid,
                   type: Integer,
                   desc: 'The unique id of operation\'s reference, for which operation was created.'
          optional :code,
                   type: Integer,
                   desc: 'Opeartion\'s code.'
          optional :credit_from,
                   type: BigDecimal,
                   desc: -> { API::V2::Admin::Entities::Operation.documentation[:credit][:desc] }
          optional :credit_to,
                   type: BigDecimal,
                   desc: -> { API::V2::Admin::Entities::Operation.documentation[:credit][:desc] }
          optional :debit_from,
                   type: BigDecimal,
                   desc: -> { API::V2::Admin::Entities::Operation.documentation[:debit][:desc] }
          optional :debit_to,
                   type: BigDecimal,
                   desc: -> { API::V2::Admin::Entities::Operation.documentation[:debit][:desc] }
          optional :created_at_from,
                   type: { value: Integer, message: 'admin.deposit.non_integer_created_at_from' },
                   allow_blank: { value: false, message: 'admin.deposit.empty_time_from' },
                   desc: "An integer represents the seconds elapsed since Unix epoch."\
                         "If set, only operations created after the time will be returned."
          optional :created_at_to,
                   type: { value: Integer, message: 'admin.deposit.non_integer_created_at_to' },
                   allow_blank: { value: false, message: 'admin.deposit.empty_time_to' },
                   desc: "An integer represents the seconds elapsed since Unix epoch."\
                         "If set, only operations created before the time will be returned."
          optional :ordering,
                   type: String,
                   values: { value: %w(asc desc), message: 'admin.deposit.invalid_ordering' },
                   default: 'asc',
                   desc: 'If set, returned operations will be sorted in specific order, defaults to \'asc\'.'
          optional :order_by,
                   default: 'id',
                   type: String,
                   desc: 'Name of the field to order operations by.'
          optional :page,
                   type: Integer, default: 1,
                   integer_gt_zero: true,
                   desc: 'The page number (defaults to 1).'
          optional :limit,
                   type: Integer,
                   default: 100,
                   range: 1..1000,
                   desc: 'The number of objects per page (defaults to 100, maximum is 1000).'
        end
      end
    end
  end
end
