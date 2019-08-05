# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      class Trades < Grape::API
        helpers ::API::V2::Admin::Helpers

        desc 'Get all trades, result is paginated.',
          is_array: true,
          success: API::V2::Admin::Entities::Trade
        params do
          optional :market,
                   values: { value: -> { ::Market.enabled.ids }, message: 'admin.market.doesnt_exist' },
                   desc: -> { API::V2::Admin::Entities::Market.documentation[:id][:desc] }
          optional :order_id,
                   type: Integer,
                   desc: -> { API::V2::Entities::Order.documentation[:id][:desc] }
          use :uid
          use :date_picker, keys: %w[created_at]
          use :pagination
          use :ordering
        end
        get '/trades' do
          authorize! :read, Trade

          ransack_params = Helpers::RansackBuilder.new(params)
                             .map(market_id: :market)
                             .build(g: [
                               { ask_member_uid_eq: params[:uid], bid_member_uid_eq: params[:uid], m: 'or' },
                               { ask_id_eq: params[:order_id], bid_id_eq: params[:order_id], m: 'or' },
                             ])

          search = Trade.ransack(ransack_params)
          search.sorts = "#{params[:order_by]} #{params[:ordering]}"
          present paginate(search.result), with: API::V2::Admin::Entities::Trade
        end
      end
    end
  end
end
