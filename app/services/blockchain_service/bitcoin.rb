# encoding: UTF-8
# frozen_string_literal: true
module BlockchainService
  class Bitcoin < Base

    def process_blockchain(blocks_limit: 10)
      current_block   = blockchain.height || 0
      latest_block    = [client.latest_block_number, current_block + blocks_limit].min

      (current_block..latest_block).each do |block_id|

        Rails.logger.info { "Started processing #{blockchain.key} block number #{blockchain.height}." }

        block_hash = client.get_block_hash(block_id)
        next if block_hash.blank?

        block_json = client.get_block(block_hash)
        next if block_json.blank? || block_json['tx'].blank?

        deposits    = build_deposits(block_json, block_id, latest_block)
        withdrawals = build_withdrawals(block_json, block_id, latest_block)

        update_or_create_deposits!(deposits)
        update_withdrawals!(withdrawals)

        # Mark block as processed if both deposits and withdrawals were confirmed.
        blockchain.update(height: block_id) if latest_block - block_id > blockchain.min_confirmations

        Rails.logger.info { "Finished processing #{blockchain.key} block number #{blockchain.height}." }
      rescue => e
        report_exception(e)
      end
    end

    private

    def build_deposits(block_json, block_id, latest_block)
      block_json
        .fetch('tx')
        .each_with_object([]) do |tx, deposits|

        payment_addresses_where(address: client.to_address(tx)) do |payment_address|
          # If payment address currency doesn't match with blockchain

          deposit_txs = client.build_transaction(tx, block_id, latest_block, payment_address.address)

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

    def build_withdrawals(block_json, block_id, latest_block)
      block_json
        .fetch('tx')
        .each_with_object([]) do |tx, withdrawals|

        Withdraws::Coin.where(currency: currencies, txid: client.normalize_txid(tx.fetch('txid'))).each do |withdraw|
          # If wallet currency doesn't match with blockchain transaction

          withdraw_txs = client.build_transaction(tx, block_id, latest_block, withdraw.rid)
          withdraw_txs.fetch(:entries).each do |entry|
            withdrawals << {  txid:           withdraw_txs[:id],
                              rid:            entry[:address],
                              sum:            entry[:amount],
                              confirmations:  withdraw_txs[:confirmations] }
          end
        end
      end
    end
  end
end

