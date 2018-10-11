# encoding: UTF-8
# frozen_string_literal: true

module WalletService
  class Bitcoind < Base

    def create_address(options = {})
      @client.create_address!(options)
    end

    def collect_deposit!(deposit, options={})
      destination_wallets = destination_wallets(deposit)
      pa = deposit.account.payment_address

      # this will automatically deduct fee from amount
      options = options.merge( subtract_fee: true )
      deposit_amount = deposit.amount
      destination_wallets.each do |wallet|
        break if deposit_amount == 0
        wallet_balance = client.load_balance!
        if wallet_balance + deposit_amount > wallet.max_balance
          amount_left = wallet.max_balance - wallet_balance
          next if amount_left < Currency.find(wallet.currency_id).min_deposit_amount
          client.create_withdrawal!(
              { address: pa.address },
              { address: wallet.address },
              amount_left,
              options
          )
          deposit_amount -= amount_left
        else
          client.create_withdrawal!(
              { address: pa.address },
              { address: wallet.address },
              deposit_amount,
              options
          )
          break
        end
      end
    end

    def build_withdrawal!(withdraw, options = {})
      client.create_withdrawal!(
        { address: wallet.address },
        { address: withdraw.rid },
        withdraw.amount,
        options
      )
    end
  end
end
