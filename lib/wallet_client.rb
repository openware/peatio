# encoding: UTF-8
# frozen_string_literal: true

module WalletClient
  Error                  = Class.new(StandardError) # TODO: Rename to Exception.
  ConnectionRefusedError = Class.new(StandardError) # TODO: Remove this.

  class << self
    #
    # Returns API client for given gateway options hash.
    #
    # @param wallet [String, Symbol]
    #   The wallet object.
    # @return [BaseAPI]
    def [](wallet)
      "WalletClient::#{wallet.gateway.fetch('client').capitalize}"
        .constantize
        .new(wallet)
    end
  end

  class Base
    extend Memoist

    #
    # Returns the blockchain.
    #
    # @return [gateway]
    attr_reader :wallet

    def initialize(wallet)
      @wallet = wallet
    end

    def normalize_address(address)
      address
    end

    def normalize_txid(txid)
      txid
    end

    def convert_from_base_unit(value, currency)
      value.to_d / currency.base_factor
    end
  end
end
