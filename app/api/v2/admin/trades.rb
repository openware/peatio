# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      class Trades < Grape::API
        helpers API::V2::Admin::TradeParams
        helpers API::V2::Admin::ParamsHelpers

        desc 'Get all trades, result is paginated.',
          is_array: true,
          success: API::V2::Admin::Entities::Trade
        params do
          use :trade_params
        end
        get '/trades' do
          authorize! :read, Trade

          ransack_params = {
            price_gteq: params[:price_from],
            price_lt: params[:price_to],
            volume_gteq: params[:volume_from],
            volume_lt: params[:volume_to],
            market_id_eq: params[:market],
            created_at_gteq: time_param(params[:created_at_from]),
            created_at_lt: time_param(params[:created_at_to]),
            g: [
              { ask_member_uid_eq: params[:uid], bid_member_uid_eq: params[:uid], m: 'or' },
              { ask_id_eq: params[:order_id], bid_id_eq: params[:order_id], m: 'or' },
            ],
          }

          search = Trade.ransack(ransack_params)
          search.sorts = "#{params[:order_by]} #{params[:ordering]}"
          present paginate(search.result), with: API::V2::Admin::Entities::Trade
        end
      end
    end
  end
end
