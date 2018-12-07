# encoding: UTF-8
# frozen_string_literal: true

module APIv2
  class Trades < Grape::API
    get "/trades/my" do
      authenticate!
      trading_must_be_permitted!

      trades = Trade.for_member(
        params[:market], current_user,
        limit: params[:limit], time_to: time_to,
        from: params[:from], to: params[:to],
        order: order_param
      )

      present trades, with: APIv2::Entities::Trade, current_user: current_user
    end

  end
end
