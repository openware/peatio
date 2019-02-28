# encoding: UTF-8
# frozen_string_literal: true

module WalletService
  class Bitgo < Base

    def process_blockchain!
      block = {}
      Rails.logger.info { "Processing Bitgo #{wallet.currency.code.upcase} deposits." }
      options   = client.is_a?(WalletClient::Ethereum) ? { transactions_limit: 100 } : { }
      block[:deposits] = client.fetch_deposits(options)
      latest_block_number = client.latest_block_number
      Rails.logger.info { "Finished processing #{wallet.currency.code.upcase} deposits." }
      return block, latest_block_number
    rescue => e
      report_exception(e)
    end

    def create_address(options = {})
      @client.create_address!(options)
    end

    def collect_deposit!(deposit, options={})
      destination_address = destination_wallet(deposit).address
      pa = deposit.account.payment_address

      # This builds a transaction object, but does not sign or send it.
      fee = client.build_raw_transaction(
          { address: destination_address },
          deposit.amount
      )

      # We can't collect all funds we need to subtract txn fee.
      amount = deposit.amount - fee

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

    def load_balance(address, currency)
      client.load_balance!(address, currency)
    end
  end
end
