# encoding: UTF-8
# frozen_string_literal: true

module BlockchainServices
  class Bitcoin < Peatio::BlockchainService::Abstract

    BlockGreaterThanLatestError = Class.new(StandardError)
    FetchBlockError = Class.new(StandardError)
    EmptyCurrentBlockError = Class.new(StandardError)

    include Peatio::BlockchainService::Helpers

    delegate :supports_cash_addr_format?, :case_sensitive?, to: :client

    def fetch_block!(block_number)
      raise BlockGreaterThanLatestError if block_number > latest_block_number

      block_hash = client.get_block_hash(block_number)
      raise FetchBlockError if block_hash.blank?

      @block_json = client.get_block(block_hash)
      if @block_json.blank? || !@block_json.key?('tx')
        raise FetchBlockError
      end
    end

    def current_block_number
      require_current_block!
      @block_json['height'].to_i
    end

    def latest_block_number
      @cache.fetch(cache_key(:latest_block), expires_in: 5.seconds) do
        client.latest_block_number
      end
    end

    def client
      @client ||= BlockchainClient::Bitcoin.new(@blockchain)
    end

    def filtered_deposits(payment_addresses, &block)
      require_current_block!
      @block_json
        .fetch('tx')
        .each_with_object([]) do |block_txn, deposits|

        payment_addresses
          .where(address: client.to_address(block_txn))
          .each do |payment_address|
            deposit_txs = client.build_transaction(block_txn, current_block_number, payment_address.address)

            deposit_txs.fetch(:entries).each do |entry|
              deposit = { txid:           deposit_txs[:id],
                          address:        entry[:address],
                          amount:         entry[:amount],
                          member:         payment_address.account.member,
                          currency:       payment_address.currency,
                          txout:          entry[:txout],
                          block_number:   deposit_txs[:block_number] }

              block.call(deposit) if block_given?
              deposits << deposit
            end
        end
      end
    end

    def filtered_withdrawals(withdrawals, &block)
      require_current_block!

      @block_json
        .fetch('tx')
        .each_with_object([]) do |block_txn, withdrawals_h|

        withdrawals
          .where(txid: client.normalize_txid(block_txn.fetch('txid')))
          .each do |withdraw|

          withdraw_txs = client.build_transaction(block_txn, current_block_number, withdraw.rid)
          withdraw_txs.fetch(:entries).each do |entry|
            withdrawal =  { txid:           withdraw_txs[:id],
                            rid:            entry[:address],
                            amount:         entry[:amount],
                            block_number:   withdraw_txs[:block_number] }
            block.call(withdrawal) if block_given?
            withdrawals_h << withdrawal
          end
        end
      end
    end

    private
    def require_current_block!
      raise EmptyCurrentBlockError if @block_json.blank?
    end
  end
end

