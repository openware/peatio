# encoding: UTF-8
# frozen_string_literal: true

module WalletService
  class Nxt < Base

    def create_address(options = {})
      @client.create_address!(options)
    end

    def collect_deposit!(deposit, options={})
      destination_address = destination_wallet(deposit).address

      if deposit.currency.code.nxt?
        collect_coin_deposit(deposit, destination_address, options={})
      else
        collect_currency_deposit(deposit, destination_address, options={})
      end
    end

    def build_withdrawal!(withdraw, options = {})
      if withdraw.currency.code.nxt?
        build_coin_withdrawal(withdraw, options = {})
      else
        build_currency_withdrawal(withdraw, options = {})
      end
    end

    def deposit_collection_fees(deposit, value=1, options={})
      fees_wallet = nxt_fees_wallet
      destination_address = deposit.account.payment_address.address

      client.create_coin_withdrawal!(
          { address: fees_wallet.address, secret: fees_wallet.secret },
          { address: destination_address },
          value,
          options
      )
    end

    private

    def nxt_fees_wallet
      Wallet
          .active
          .withdraw
          .find_by(currency_id: :nxt, kind: :hot)
    end

    def collect_coin_deposit(deposit, destination_address, options={})
      pa = deposit.account.payment_address

      amount = deposit.amount - 1 #TODO more research for NXT txn fee

      client.create_coin_withdrawal!(
          { address: pa.address, secret: pa.secret },
          { address: destination_address },
          amount,
          options
      )
    end

    def collect_currency_deposit(deposit, destination_address, options={})
      pa = deposit.account.payment_address

      client.create_currency_withdrawal!(
          { address: pa.address, secret: pa.secret },
          { address: destination_address },
          deposit.amount,
          options.merge(nxt_currency_id: deposit.currency.nxt_currency_id)
      )
    end

    def build_coin_withdrawal(withdraw, options = {})
      client.create_coin_withdrawal!(
          { address: wallet.address, secret: wallet.secret },
          { address: withdraw.rid },
          withdraw.amount,
          options
      )
    end

    def build_currency_withdrawal(withdraw, options = {})
      client.create_currency_withdrawal!(
          { address: wallet.address, secret: wallet.secret },
          { address: withdraw.rid },
          withdraw.amount,
          options.merge(nxt_currency_id: withdraw.currency.nxt_currency_id)
      )
    end
  end
end
