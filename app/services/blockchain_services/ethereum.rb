# encoding: UTF-8
# frozen_string_literal: true

module BlockchainServices
  class Ethereum < Peatio::BlockchainService::Abstract
    BlockGreaterThanLatestError = Class.new(StandardError)
    FetchBlockError = Class.new(StandardError)
    EmptyCurrentBlockError = Class.new(StandardError)

    include Peatio::BlockchainService::Helpers

    delegate :supports_cash_addr_format?, :case_sensitive?, to: :client

    def fetch_block!(block_number)
      raise BlockGreaterThanLatestError if block_number > latest_block_number

      @block_json = client.get_block(block_number)
      if @block_json.blank? || !@block_json.key?('transactions')
        raise FetchBlockError
      end
    end

    def current_block_number
      require_current_block!
      @block_json['number'].to_i(16)
    end

    def latest_block_number
      @cache.fetch(cache_key(:latest_block), expires_in: 5.seconds) do
        client.latest_block_number
      end
    end

    def client
      @client ||= BlockchainClient::Ethereum.new(@blockchain)
    end

    def filtered_deposits(payment_addresses, &block)
      require_current_block!
      @block_json
        .fetch('transactions')
        .each_with_object([]) do |block_txn, deposits|

        if block_txn.fetch('input').hex <= 0
          txn = block_txn
          next if client.invalid_eth_transaction?(txn)
        else
          txn = client.get_txn_receipt(block_txn.fetch('hash'))
          next if txn.nil? || client.invalid_erc20_transaction?(txn)
        end

        payment_addresses
          .where(address: client.to_address(txn))
          .each do |payment_address|
            deposit_txs = client.build_transaction(txn, @block_json,
                                                   payment_address.address,
                                                   payment_address.currency)
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
        .fetch('transactions')
        .each_with_object([]) do |block_txn, withdrawals_h|

        withdrawals
          .where(txid: block_txn.fetch('hash'))
          .each do |withdraw|

          if block_txn.fetch('input').hex <= 0
            txn = block_txn
            next if client.invalid_eth_transaction?(txn)
          else
            txn = client.get_txn_receipt(block_txn.fetch('hash'))
            if txn.nil? || client.invalid_erc20_transaction?(txn)
              # Call block for unsuccessful txid.
              block.call({ txid: block_txn.fetch('hash') }, false) if block_given?
              next
            end
          end

          withdraw_txs = client.build_transaction(txn, @block_json, withdraw.rid, withdraw.currency)
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
