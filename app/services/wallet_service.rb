# encoding: UTF-8
# frozen_string_literal: true

class WalletService
  Error                  = Class.new(StandardError) # TODO: Rename to Exception.
  ConnectionRefusedError = Class.new(StandardError) # TODO: Remove this.

  class << self
    #
    # Returns WalletService for given wallet.
    #
    # @param wallet [String, Symbol]
    #   The wallet record in database.
    def [](wallet)
      # wallet_service = wallet.gateway.capitalize
      # "WalletService::#{wallet_service}"
      #   .constantize
      #   .new(wallet)
      WalletService.new(wallet)
    end
  end

  attr_reader :wallet, :adapter

  delegate :spread_deposit, :destination_wallets, to: :adapter

  def initialize(wallet)
    @wallet = wallet
    @adapter = Peatio::WalletService
                  .get_adapter(wallet.gateway.to_sym)
                  .new(wallet: wallet)
    # @client = WalletClient[wallet]
  end

  def collect_deposit!(deposit, options = {})
    @adapter.collect_deposit!(deposit, options)
  end

  # TODO: Rename this method.
  def build_withdrawal!(withdraw, options = {})
    @adapter.build_withdrawal!(withdraw, options)
  end

  def deposit_collection_fees(deposit)
    @adapter.deposit_collection_fees(deposit)
  end

  def load_balance(address, currency)
    @adapter.load_balance(address, currency)
  end

  # TODO: Rename this method.
  def create_address(options = {})
    @adapter.create_address!(options)
  end

end
