# frozen_string_literal: true

module API
  module V2
    module CoinGecko
      module Helpers
        MILLISECONDS_IN_SECOND = 1000

        def format_ticker(ticker, market)
          lowest_ask = OrderAsk.get_depth(market.id) # Is it ok to return nil?
          highest_bid = OrderBid.get_depth(market.id)
          {
            ticker_id: "#{market[:base_unit].upcase}_#{market[:quote_unit].upcase}",
            base_currency: market[:base_unit].upcase,
            target_currency: market[:quote_unit].upcase,
            last_price: ticker[:last],
            base_volume: ticker[:amount],
            target_volume: ticker[:volume],
            bid: highest_bid.flatten.first,
            ask: lowest_ask.flatten.first,
            high: ticker[:high],
            low: ticker[:low]
          }
        end

        def format_orderbook(asks, bids, market)
          {
            ticker_id: "#{market[:base_unit].upcase}_#{market[:quote_unit].upcase}",
            timestamp: DateTime.now.strftime('%Q').to_i,
            asks: asks,
            bids: bids
          }
        end

        def format_trade(trade)
          {
            trade_id: trade[:id],
            price: trade[:price],
            base_volume: trade[:amount],
            target_volume: trade[:total],
            trade_timestamp: trade[:created_at] * MILLISECONDS_IN_SECOND,
            type: trade[:taker_type]
          }
        end
      end
    end
  end
end
