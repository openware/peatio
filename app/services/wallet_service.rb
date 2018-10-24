# encoding: UTF-8
# frozen_string_literal: true

module WalletService
  Error                  = Class.new(StandardError) # TODO: Rename to Exception.
  ConnectionRefusedError = Class.new(StandardError) # TODO: Remove this.

  class << self
    #
    # Returns WalletService for given wallet.
    #
    # @param wallet [String, Symbol]
    #   The wallet record in database.
    def [](wallet)
      wallet_service = wallet.gateway.capitalize
      "WalletService::#{wallet_service}"
        .constantize
        .new(wallet)
    rescue NameError
      raise Error, "Wrong WalletService name #{wallet_service}"
    end
  end

  class Base

    attr_accessor :wallet, :client

    def initialize(wallet)
      @wallet = wallet
      @client = WalletClient[wallet]
    end

    def collect_deposit!(deposit)
      method_not_implemented
    end

    # TODO: Rename this method.
    def build_withdrawal!(withdraw)
      method_not_implemented
    end

    # TODO: Rename this method.
    def create_address!
      method_not_implemented
    end

    # TODO: Move to protected
    def spread_deposit(deposit=Deposit.new(amount: 1, currency_id: :btc))
      left_amount = deposit.amount
      collection_spread = Hash.new(0)
      currency = deposit.currency
      destination_wallets(deposit).each do |wallet|
          break if left_amount == 0
          wallet_balance = client.load_balance!(wallet.address)
          amount_for_wallet = [wallet.max_balance - wallet_balance, left_amount].min
          # TODO: amount_for_wallet <= currency.min_deposit_amount
          next if amount_for_wallet <= 0
          left_amount -= amount_for_wallet
          # If amount left is too small we will not able to collect it.
          # So we collect everything to current wallet.
          #
          # NOTE: Uncomment once we merge min_deposit_amount
          #
          # if left_amount < currency.min_deposit_amount
          #   amount_for_wallet += left_amount
          #   left_amount = 0
          # end
          collection_spread[wallet.address] = amount_for_wallet
      end
      # If deposit doesn't fit to any wallet collect it to last wallet.
      # Last wallet is considered to be the most secure.
      if left_amount > 0
        collection_spread[destination_wallets(deposit).last.address] += left_amount
        left_amount = 0
      end
      collection_spread
    end

    protected

    def destination_wallets(deposit)
      Wallet
        .active
        .withdraw
        .ordered
        .where(currency_id: deposit.currency_id)
    end
  end
end
