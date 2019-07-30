# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      class Operations < Grape::API
        helpers API::V2::Admin::OperationParams
        helpers API::V2::Admin::ParamsHelpers
        helpers do
          def ransack_params
            {
              currency_id_eq: params[:currency],
              reference_type_eq: params[:reference_type],
              reference_id_eq: params[:rid],
              code_eq: params[:code],
              credit_gteq: params[:credit_from],
              credit_lt: params[:credit_to],
              debit_gteq: params[:debit_from],
              debit_lt: params[:debit_to],
              created_at_gteq: time_param(params[:created_at_from]),
              created_at_lt: time_param(params[:created_at_to]),
            }
          end
        end

        # GET: api/v2/admin/assets
        # GET: api/v2/admin/expenses
        # GET: api/v2/admin/revenues
        ::Operations::Account::PLATFORM_TYPES.each do |op_type|
          op_type_plural = op_type.to_s.pluralize

          desc "Returns #{op_type_plural} as a paginated collection." do
            success API::V2::Admin::Entities::Operation
          end
          params do
            use :get_operations_params
          end
          get op_type_plural do
            klass = ::Operations.const_get(op_type.capitalize)
            authorize! :read, klass

            search = klass.ransack(ransack_params)
            search.sorts = "#{params[:order_by]} #{params[:ordering]}"

            present paginate(search.result), with: API::V2::Admin::Entities::Operation
          end
        end

        # Get: api/v2/admin/liabilities
        ::Operations::Account::MEMBER_TYPES.each do |op_type|
          op_type_plural = op_type.to_s.pluralize

          desc "Returns #{op_type_plural} as a paginated collection." do
            success API::V2::Admin::Entities::Operation
          end
          params do
            use :get_operations_params
            optional :uid,
                     type: String,
                     desc: 'The user ID for operations filtering.'
          end
          get op_type_plural do
            klass = ::Operations.const_get(op_type.capitalize)
            authorize! :read, klass

            search = klass.ransack(ransack_params.merge(member_uid_eq: params[:uid]))
            search.sorts = "#{params[:order_by]} #{params[:ordering]}"

            present paginate(search.result), with: API::V2::Admin::Entities::Operation
          end
        end
      end
    end
  end
end
