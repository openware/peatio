# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      class Orders < Grape::API
        helpers ::API::V2::Admin::NamedParams

        desc 'Get all orders, results is paginated.',
          is_array: true,
          success: API::V2::Admin::Entities::Order
        params do
          use :orders_param
          use :paginate_param
        end
        get '/orders' do
          authorize! :read, Order

          ransack_params = {
            price_eq: params[:price],
            origin_volume_eq: params[:origin_volume],
            ord_type_eq: params[:ord_type],
            state_eq: params[:state].present? ? Order::STATES[params[:state].to_sym] : nil,
            market_id_eq: params[:market],
            type_eq: params[:type].present? ? params[:type] == 'buy' ? 'OrderBid' : 'OrderAsk' : nil,
            member_uid_eq: params[:uid],
            member_email_eq: params[:email],
            created_at_gteq: params[:created_at_from].present? ? Time.at(params[:created_at_from]) : nil,
            created_at_lt: params[:created_at_to].present? ? Time.at(params[:created_at_to]) : nil,
            updated_at_gteq: params[:updated_at_from].present? ? Time.at(params[:updated_at_from]) : nil,
            updated_at_lt: params[:updated_at_to].present? ? Time.at(params[:updated_at_to]) : nil
          }

          order_collection = Order.ransack(ransack_params).result
          present paginate(order_collection), with: API::V2::Admin::Entities::Order
        end
      end
    end
  end
end
