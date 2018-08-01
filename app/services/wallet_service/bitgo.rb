# encoding: UTF-8
# frozen_string_literal: true

module WalletService
  class Bitgo < Base

    DEFAULT_BTC_FEE = { fee: 0.00001327 }.freeze

    def create_address(options = {})
      @client.create_address!(options)
    end

    def collect_deposit!(deposit, options={})
      destination_address = destination_wallet(deposit).address
      pa = deposit.account.payment_address

      options = DEFAULT_BTC_FEE.merge options

      # We can't collect all funds we need to subtract gas fees.
      amount = deposit.amount - options[:fee]

      client.create_withdrawal!(
          { address: pa.address },
          { address: destination_address },
          amount,
          options
      )
    end

    def destination_wallet(deposit)
      # TODO: Dynamicly check wallet balance and select where to send funds.
      # For keeping it simple we will collect all funds to hot wallet.
      Wallet
          .active
          .withdraw
          .find_by(currency_id: deposit.currency_id, kind: :hot)
    end

    def build_withdrawal!(withdraw, options = {})
      client.create_withdrawal!(
          { address: wallet.address },
          { address: withdraw.rid },
          withdraw.amount,
          options
      )
    end

    def load_balance(currency = nil)
      client.load_balance!
    end

  end
end
