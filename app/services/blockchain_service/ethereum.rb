# encoding: UTF-8
# frozen_string_literal: true
module BlockchainService
  class Ethereum < Base

    def process_blockchain
      current_block   = @blockchain.height || 0
      latest_block    = @client.latest_block_number

      (current_block..latest_block).each do |block_id|
        block_json = @client.get_block(block_id)

        next if block_json.blank?
        transactions = block_json.fetch('transactions')
        deposits = build_deposits(transactions, block_json, latest_block)

        save_deposits!(deposits)

        # Mark block as processed if both deposits and withdrawals were confirmed.
        @blockchain.update(height: block_id) if latest_block - block_id > @blockchain.min_confirmations
        # TODO: exceptions processing.
      end
    end

    private

    def build_deposits(transactions, block_json, latest_block)
      transactions.each_with_object([]) do |tx, deposits|
        next if @client.invalid_transaction?(tx)

        payment_addresses_where(address: @client.to_address(tx)) do |payment_address|
          # If payment address currency doesn't match with blockchain
          # transaction currency skip this payment address.
          next if payment_address.currency.code.eth? != @client.is_eth_tx?(tx)

          deposit_txs = @client.build_deposit(tx, block_json, latest_block, payment_address.currency)
          deposit_txs.fetch(:entries).each_with_index do |entry, i|
            deposits << { txid:           deposit_txs[:id],
                          address:        entry[:address],
                          amount:         entry[:amount],
                          member:         payment_address.account.member,
                          currency:       payment_address.currency,
                          txout:          i,
                          confirmations:  deposit_txs[:confirmations] }
          end
        end
      end
    end
  end
end

