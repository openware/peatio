# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module CoinGecko
      class Pairs < Grape::API
        desc 'Get list of all available trading pairs'
        get "/pairs" do
          enabled_markets = ::Market.enabled
          present enabled_markets, with: API::V2::CoinGecko::Entities::Pair
        end
      end
    end
  end
end
