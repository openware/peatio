# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Public
      class Config < Grape::API
        get '/config' do
          present :blockchains, Blockchain.active, with: Entities::Blockchain
          present :currencies, Currency.visible, with: Entities::Currency
          present :trading_fees, TradingFee.all, with: Entities::TradingFee
          present :markets, ::Market.enabled, with: Entities::Market
          present :withdraw_limits, WithdrawLimit.all, with: Entities::WithdrawLimit
        end
      end
    end
  end
end

