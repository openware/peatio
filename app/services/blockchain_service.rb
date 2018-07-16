# encoding: UTF-8
# frozen_string_literal: true

module BlockchainService
  Error                  = Class.new(StandardError) # TODO: Rename to Exception.
  ConnectionRefusedError = Class.new(StandardError) # TODO: Remove this.

  class << self
    #
    # Returns Service for given blockchain key.
    #
    # @param code [String, Symbol]
    #   The blockchain key.
    def [](key)
      blockchain = Blockchain.find_by_key(key)
      if blockchain.try(:client).present?
        "BlockchainService::#{blockchain.client.capitalize}"
      end.constantize.new(blockchain)
    end
  end

  class Base

    def initialize(blockchain)
      @blockchain = blockchain
      @client     = Client[blockchain.key]
    end

    def current_height
      @blockchain.height
    end

    protected

    def save_deposits!(deposits)
      deposits.each do |deposit_hash|

        # If deposit doesn't exist create it.
        deposit = Deposits::Coin.find_or_create_by!(deposit_hash.except(:confirmations))

        # Otherwise update confirmations amount for existing deposit.
        if deposit.confirmations != deposit_hash.fetch(:confirmations)
          deposit.update(confirmations: deposit_hash.fetch(:confirmations))
          deposit.accept! if deposit.confirmations >= @blockchain.min_confirmations
        end
      end
    end

    def payment_addresses_where(options)
      options = { currency_id: @blockchain.currencies.pluck(:id) }.merge(options)
      PaymentAddress
          .where(options)
          .each do |payment_address|
        yield payment_address if block_given?
      end
    end
  end
end
