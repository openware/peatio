# encoding: UTF-8
# frozen_string_literal: true

module WalletService
  class Geth < Base

    def create_address(options = {})
      @client.create_address!(options)
    end

    def load_balance(currency)
     @client.load_balance!(currency)
    end

    def create_withdrawal(pa, withdraw)
      if withdraw.currency.code.eth?
        @client.create_eth_withdrawal!(
          { address: pa.address, secret: pa.secret },
          { address: withdraw.rid },
          withdraw.amount.to_d,
          withdraw.currency
        )
      else
        @client.create_erc20_withdrawal!(
          { address: pa.address, secret: pa.secret },
          { address: withdraw.rid },
          withdraw.amount.to_d,
          withdraw.currency
        )
      end

    end

  end
end
