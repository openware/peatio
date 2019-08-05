# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      class Orders < Grape::API
        helpers ::API::V2::Admin::Helpers

        desc 'Get all orders, result is paginated.',
          is_array: true,
          success: API::V2::Admin::Entities::Order
        params do
          optional :market,
                   values: { value: -> { ::Market.enabled.ids }, message: 'admin.market.doesnt_exist' },
                   desc: -> { API::V2::Admin::Entities::Market.documentation[:id][:desc] }
          optional :state,
                   values: { value: -> { ::Order.state.values }, message: 'admin.order.invalid_state' },
                   desc: 'Filter order by state.'
          optional :ord_type,
                   values: { value: ::Order::TYPES, message: 'admin.order.invalid_ord_type' },
                   desc: 'Filter order by ord_type.'
          optional :price,
                   type: { value: BigDecimal, message: 'admin.order.non_decimal_price' },
                   values: { value: -> (p){ p.try(:positive?) }, message: 'admin.order.non_positive_price' },
                   desc: -> { API::V2::Admin::Entities::Order.documentation[:price][:desc] }
          optional :origin_volume,
                   type: { value: BigDecimal, message: 'admin.order.non_decimal_price' },
                   values: { value: -> (p){ p.try(:positive?) }, message: 'admin.order.non_positive_origin_volume' },
                   desc: -> { API::V2::Admin::Entities::Order.documentation[:origin_volume][:desc] }
          optional :type,
                   values: { value: %w(buy sell), message: 'admin.order.invalid_type' },
                   desc: 'Filter order by type.'
          optional :email,
                   desc: -> { API::V2::Entities::Member.documentation[:email][:desc] }
          use :uid
          use :date_picker, keys: %w[updated_at created_at]
          use :pagination
          use :ordering
        end
        get '/orders' do
          authorize! :read, Order

          ransack_params = Helpers::RansackBuilder.new(params)
                             .eq(:price, :origin_volume, :ord_type)
                             .map(market_id: :market, member_uid: :uid, member_email: :email)
                             .build({
                                state_eq: params[:state].present? ? Order::STATES[params[:state].to_sym] : nil,
                                type_eq: params[:type].present? ? "Order#{params[:type].capitalize}" : nil,
                             })

          search = Order.ransack(ransack_params)
          search.sorts = "#{params[:order_by]} #{params[:ordering]}"
          present paginate(search.result), with: API::V2::Admin::Entities::Order
        end
      end
    end
  end
end
