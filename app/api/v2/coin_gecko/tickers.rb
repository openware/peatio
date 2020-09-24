# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module CoinGecko
      class Tickers < Grape::API
        desc 'Get list of all available trading pairs'
        get "/tickers" do
          enabled_markets = ::Market.enabled.ordered

          tickers = enabled_markets.map do |market|
            format_ticker(TickersService[market].ticker, market)
          end

          present tickers, with: API::V2::CoinGecko::Entities::Ticker
        end
      end
    end
  end
end
