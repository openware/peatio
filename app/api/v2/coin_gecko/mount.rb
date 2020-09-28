# frozen_string_literal: true

module API
  module V2
    module CoinGecko
      class Mount < Grape::API
        PREFIX = '/coingecko'

        before { set_ets_context! }

        mount CoinGecko::Pairs
        mount CoinGecko::Tickers
        mount CoinGecko::Orderbook
        mount CoinGecko::HistoricalTrades
      end
    end
  end
end
