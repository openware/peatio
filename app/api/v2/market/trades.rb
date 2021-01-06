# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Market
      class Trades < Grape::API
        helpers API::V2::Market::NamedParams

        desc 'Get your executed trades. Trades are sorted in reverse creation order.',
          is_array: true,
          success: API::V2::Entities::Trade
        params do
          optional :market,
                   values: { value: ->(v) { (Array.wrap(v) - ::Market.active.ids).blank? }, message: 'market.market.doesnt_exist' },
                   desc: -> { V2::Entities::Market.documentation[:id] }
          use :trade_filters
        end
        get '/trades' do
          user_authorize! :read, ::Trade
          # for sell orders query should be (when params[:type] == sell)
          # where("taker_id = #{current_user.id} AND taker_type = 'sell' OR maker_id = #{current_user.id} AND taker_type = 'buy'")

          # for buy orders query should be (when params[:type] == buy)
          # where("taker_id = #{current_user.id} AND taker_type = 'buy' OR maker_id = #{current_user.id} AND taker_type = 'sell')

          # If you want you can rewrite those filters with ransack (you can see a lot of examples on admin API endpoints)

          # write specs on spec/market/trades_spec.rb

          # it should be at least 4 tests
          # 1) taker_id = current_user.id AND taker_type = 'sell' (should give you as trades with sell side)
          # 2) maker_id = current_user.id AND taker_type = 'buy' (should give you as trades with sell side)
          # 3) taker id = current_user.id AND taker_type = 'buy' (should give you as trades with buy side)
          # 4) maker_id = current_user.id AND taker_type = 'sell' (should give you as trades with buy side)

          current_user
            .trades
            .order(order_param)
            .tap { |q| q.where!(market: params[:market]) if params[:market] }
            .tap { |q| q.where!('created_at >= ?', Time.at(params[:time_from])) if params[:time_from] }
            .tap { |q| q.where!('created_at < ?', Time.at(params[:time_to])) if params[:time_to] }
            .tap { |q| present paginate(q, false), with: API::V2::Entities::Trade, current_user: current_user }
        end
      end
    end
  end
end
