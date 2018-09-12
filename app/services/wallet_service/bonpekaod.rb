# encoding: UTF-8
# frozen_string_literal: true

module WalletService
  class Bonpekaod < Bitcoind

    def collect_deposit!(deposit, options={})
      destination_address = destination_wallet(deposit).address
      pa = deposit.account.payment_address

      client.create_withdrawal!(
        { address: pa.address },
        { address: destination_address },
        deposit.amount,
        options
      )

    end
  end
end
