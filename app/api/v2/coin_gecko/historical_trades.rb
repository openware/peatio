# frozen_string_literal: true

module API
  module V2
    module CoinGecko
      class HistoricalTrades < Grape::API
        desc 'Get recent trades on market'
        params do
          requires :ticker_id,
                   type: String,
                   desc: 'A pair such as "LTC_BTC"',
                   coerce_with: ->(name) { name.strip.split('_').join }
          optional :type,
                   type: String,
                   values: { value: %w(buy sell), message: 'coingecko.historical_trades.invalid_type' },
                   desc: 'To indicate nature of trade - buy/sell'
          optional :limit,
                   type: Integer,
                   values: { value: 0..1000, message: 'coingecko.historical_trades.invalid_limit' },
                   desc: 'Number of historical trades to retrieve from time of query. [0, 200, 500...]. 0 returns full history'
          optional :start_time
          optional :end_time
        end
        get '/historical_trades' do
          market = ::Market.find(params[:ticker_id])

          trade = Trade.public_from_influx_with_filters(market.id, params[:type], params[:start_time], params[:end_time], params[:limit])
          present trade, with: API::V2::CoinGecko::Entities::HistoricalTrade
        end
      end
    end
  end
end
