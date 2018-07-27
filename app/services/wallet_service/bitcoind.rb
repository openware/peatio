# encoding: UTF-8
# frozen_string_literal: true

module WalletService
  class Bitcoind < Base

    def create_address(options = {})
      @client.create_address!(options)
    end

    def load_balance(currency = nil)
      @client.load_balance!
    end

    def create_withdrawal(pa, withdraw)
      @client.create_withdrawal!(
        { address: pa.address, secret: pa.secret },
        { address: withdraw.rid },
        withdraw.amount.to_d
      )

    end

  end
end
