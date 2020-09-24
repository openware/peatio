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
        end
        get '/historical_trades' do
          market = ::Market.find(params[:ticker_id])
          formatted_trades = {
            'buy' => [],
            'sell' => []
          }
          Trade.public_from_influx(market.id).each do |trade|
            formatted_trades[trade[:taker_type]] << format_trade(trade)
          end

          formatted_trades
        end
      end
    end
  end
end
