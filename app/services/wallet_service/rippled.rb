# encoding: UTF-8
# frozen_string_literal: true

module WalletService
  class Rippled < Base
    def create_address(options = {})
      client.create_address!(options.merge(
        address: "#{wallet.address}?dt=#{generate_destination_tag}",
        secret: wallet.settings['secret']
      ))
    end

    def collect_deposit!(deposit, options={})
      destination_wallets = destination_wallets(deposit)
      pa = deposit.account.payment_address

      deposit_amount = deposit.amount * Currency.find(wallet.currency_id).base_factor
      destination_wallets.each do |wallet|
        break if deposit_amount == 0
        wallet_balance = client.load_balance!(wallet.address)
        max_balance_wallet = wallet.max_balance * Currency.find(wallet.currency_id).base_factor
        if wallet_balance + deposit_amount > max_balance_wallet
          amount_left = max_balance_wallet - wallet_balance
          next if amount_left < Currency.find(wallet.currency_id).min_deposit_amount
          client.create_withdrawal!(
            { address: pa.address, secret: pa.secret },
            { address: wallet.address },
            amount_left / Currency.find(wallet.currency_id).base_factor,
            options
          )
          deposit_amount -= amount_left
        else
          client.create_withdrawal!(
              { address: pa.address, secret: pa.secret },
              { address: wallet.address },
              deposit_amount / Currency.find(wallet.currency_id).base_factor,
              options
          )
          break
        end
      end
    end

    def build_withdrawal!(withdraw, options = {})
      client.create_withdrawal!(
        { address: wallet.address, secret: wallet.secret },
        { address: withdraw.rid },
        withdraw.amount,
        options
      )
    end

    private

    def generate_destination_tag
      begin
        # Reserve destination 1 for system purpose
        tag = SecureRandom.random_number(10**9) + 2
      end while PaymentAddress.where(currency_id: :xrp)
                              .where('address LIKE ?', "%dt=#{tag}")
                              .any?
      tag
    end
  end
end
