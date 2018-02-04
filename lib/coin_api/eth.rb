# frozen_string_literal: true

module CoinAPI
  class ETH < ::CoinAPI::JsonRPC::V2
    delegate :precision, to: :currency

    def load_balance!
      do_request(:eth_getBalance, hot_wallet_address, 'latest').hex.to_f / 10 ** precision
    end
  end
end
