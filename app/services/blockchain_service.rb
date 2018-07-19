# encoding: UTF-8
# frozen_string_literal: true

module BlockchainService
  Error                  = Class.new(StandardError) # TODO: Rename to Exception.
  ConnectionRefusedError = Class.new(StandardError) # TODO: Remove this.

  class << self
    #
    # Returns Service for given blockchain key.
    #
    # @param key [String, Symbol]
    #   The blockchain key.
    def [](key)
      blockchain = Blockchain.find_by_key(key)
      if blockchain.try(:client).present?
        "BlockchainService::#{blockchain.client.capitalize}"
      end.constantize.new(blockchain)
    end
  end

  class Base

    attr_reader :blockchain, :client

    def initialize(blockchain)
      @blockchain = blockchain
      @client     = Client[blockchain.key]
    end

    protected

    def update_or_create_deposits!(deposits)
      deposits.each do |deposit_hash|

        # If deposit doesn't exist create it.
        deposit = Deposits::Coin
                    .where(currency: currencies)
                    .find_or_create_by!(deposit_hash.except(:confirmations))

        next if deposit.confirmations == deposit_hash.fetch(:confirmations)

        # Update confirmations amount for existing deposit.
        deposit.with_lock do
          deposit.update(confirmations: deposit_hash.fetch(:confirmations))
          deposit.accept! if deposit.confirmations >= blockchain.min_confirmations
        end
      end
    end

    def update_withdrawals!(withdrawals)
      withdrawals.each do |withdrawal_hash|

        withdrawal = Withdraws::Coin
                       .where(currency: currencies)
                       .confirming
                       .find_by(withdrawal_hash.except(:confirmations))

        # Skip non-existing in database withdrawals.
        if withdrawal.blank?
          Rails.logger.info { "Skipped withdrawal: #{withdrawal_hash[:txid]}." }
          next
        end

        # Don't update withdrawal if confirmations amount is up to date.
        next if withdrawal.confirmations == withdrawal_hash.fetch(:confirmations)
        withdrawal.with_lock do
          withdrawal.update(confirmations: withdrawal_hash.fetch(:confirmations))
          withdrawal.success! if withdrawal.confirmations >= blockchain.min_confirmations
        end
      end
    end

    def current_height
      blockchain.height
    end

    def currencies
      blockchain.currencies
    end

    def payment_addresses_where(options = {})
      options = { currency: currencies }.merge(options)
      PaymentAddress
        .includes(:currency)
        .where(options)
        .each do |payment_address|
          yield payment_address if block_given?
        end
    end

    def wallets_where(options = {})
      options = { currency: currencies,
                  kind: %i[cold warm hot] }.merge(options)
      Wallet
        .includes(:currency)
        .where(options)
        .each do |wallet|
          yield wallet if block_given?
        end
    end
  end
end
