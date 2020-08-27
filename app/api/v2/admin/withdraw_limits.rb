# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      class WithdrawLimits < Grape::API
        helpers ::API::V2::Admin::Helpers

        desc 'Returns withdraw limits table as paginated collection',
          is_array: true,
          success: API::V2::Admin::Entities::WithdrawLimits
        params do
          optional :group,
                   type: String,
                   desc: -> { API::V2::Entities::WithdrawLimit.documentation[:group][:desc] },
                   coerce_with: ->(c) { c.strip.downcase }
          optional :kyc_level,
                   type: String,
                   desc: -> { API::V2::Entities::WithdrawLimit.documentation[:kyc_level][:desc] },
                   values: { value: -> { ::Currency.ids.append(::WithdrawLimit::ANY) },
                             message: 'admin.withdraw_limit.currency_doesnt_exist' }
          optional :currency_id,
                   type: String,
                   desc: -> { API::V2::Entities::WithdrawLimit.documentation[:currency_id][:desc] },
                   values: { value: -> { ::Currency.ids.append(::WithdrawLimit::ANY) },
                             message: 'admin.withdraw_limit.currency_doesnt_exist' }
          use :pagination
          use :ordering
        end
        get '/withdraw_limits' do
          admin_authorize! :read, WithdrawLimit

          ransack_params = Helpers::RansackBuilder.new(params)
                             .eq(:group, :currency_id, :kyc_level)
                             .build

          search = WithdrawLimit.ransack(ransack_params)
          search.sorts = "#{params[:order_by]} #{params[:ordering]}"

          present paginate(search.result), with: API::V2::Entities::WithdrawLimit
        end

        desc 'It creates withdraw limits record',
          success: API::V2::Entities::WithdrawLimit
        params do
          requires :l24hour,
                   type: { value: BigDecimal, message: 'admin.withdraw_limit.non_decimal_l24hour' },
                   values: { value: -> (p){ p && p >= 0 }, message: 'admin.withdraw_limit.invalid_l24hour' },
                   desc: -> { API::V2::Entities::WithdrawLimit.documentation[:l24hour][:desc] }
          requires :l1month,
                   type: { value: BigDecimal, message: 'admin.withdraw_limit.non_decimal_l1month' },
                   values: { value: -> (p){ p && p >= 0 }, message: 'admin.withdraw_limit.invalid_l1month' },
                   desc: -> { API::V2::Entities::WithdrawLimit.documentation[:l1month][:desc] }
          optional :group,
                   type: String,
                   default: ::WithdrawLimit::ANY,
                   desc: -> { API::V2::Entities::WithdrawLimit.documentation[:group][:desc] }
          optional :kyc_level,
                   type: String,
                   default: ::WithdrawLimit::ANY,
                   desc: -> { API::V2::Entities::WithdrawLimit.documentation[:kyc_level][:desc] }
          optional :currency_id,
                   type: String,
                   desc: -> { API::V2::Entities::WithdrawLimit.documentation[:currency_id][:desc] },
                   default: ::WithdrawLimit::ANY,
                   values: { value: -> { ::Currency.ids.append(::WithdrawLimit::ANY) },
                             message: 'admin.withdraw_limit.currency_id_doesnt_exist' }
        end
        post '/withdraw_limits/new' do
          admin_authorize! :create, WithdrawLimit

          withdraw_limit = ::WithdrawLimit.new(declared(params))
          if withdraw_limit.save
            present withdraw_limit, with: API::V2::Entities::WithdrawLimit
            status 201
          else
            body errors: withdraw_limit.errors.full_messages
            status 422
          end
        end

        desc 'It updates withdraw limits record',
          success: API::V2::Entities::WithdrawLimit
        params do
          requires :id,
                   type: { value: Integer, message: 'admin.withdraw_limit.non_integer_id' },
                   desc: -> { API::V2::Entities::WithdrawLimit.documentation[:id][:desc] }
          optional :l24hour,
                   type: { value: BigDecimal, message: 'admin.withdraw_limit.non_decimal_l24hour' },
                   values: { value: -> (p){ p && p >= 0 }, message: 'admin.withdraw_limit.invalid_l24hour' },
                   desc: -> { API::V2::Entities::WithdrawLimit.documentation[:l24hour][:desc] }
          optional :l1month,
                   type: { value: BigDecimal, message: 'admin.withdraw_limit.non_decimal_l1month' },
                   values: { value: -> (p){ p && p >= 0 }, message: 'admin.withdraw_limit.invalid_l1month' },
                   desc: -> { API::V2::Entities::WithdrawLimit.documentation[:l1month][:desc] }
          optional :kyc_level,
                   type: String,
                   desc: -> { API::V2::Entities::WithdrawLimit.documentation[:kyc_level][:desc] }
          optional :group,
                   type: String,
                   coerce_with: ->(c) { c.strip.downcase },
                   desc: -> { API::V2::Entities::WithdrawLimit.documentation[:group][:desc] }
          optional :currency_id,
                   type: String,
                   desc: -> { API::V2::Entities::WithdrawLimit.documentation[:currency_id][:desc] },
                   values: { value: -> { ::Currency.ids.append(::WithdrawLimit::ANY) },
                             message: 'admin.withdraw_limit.currency_doesnt_exist' }
        end
        post '/withdraw_limits/update' do
          admin_authorize! :update, WithdrawLimit

          withdraw_limit = ::WithdrawLimit.find(params[:id])
          if withdraw_limit.update(declared(params, include_missing: false))
            present withdraw_limit, with: API::V2::Entities::WithdrawLimit
          else
            body errors: withdraw_limit.errors.full_messages
            status 422
          end
        end

        desc 'It deletes withdraw limits record',
          success: API::V2::Entities::WithdrawLimit
        params do
          requires :id,
                   type: { value: Integer, message: 'admin.withdraw_limit.non_integer_id' },
                   desc: -> { API::V2::Entities::WithdrawLimit.documentation[:id][:desc] }
        end
        post '/withdraw_limits/delete' do
          admin_authorize! :delete, WithdrawLimit

          present WithdrawLimit.destroy(params[:id]), with: API::V2::Entities::WithdrawLimit
        end
      end
    end
  end
end
