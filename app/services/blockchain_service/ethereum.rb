# encoding: UTF-8
# frozen_string_literal: true

module BlockchainService
  class Ethereum < Base
    # Rough number of blocks per hour for Ethereum is 250.
    def process_blockchain(blocks_limit: 250, force: false)
      latest_block = client.latest_block_number

      # Don't start process if we didn't receive new blocks.
      if blockchain.height + blockchain.min_confirmations >= latest_block && !force
        Rails.logger.info { "Skip synchronization. No new blocks detected height: #{blockchain.height}, latest_block: #{latest_block}" }
        return
      end

      from_block   = blockchain.height || 0
      to_block     = [latest_block, from_block + blocks_limit].min

      (from_block..to_block).each do |block_id|
        Rails.logger.info { "Started processing #{blockchain.key} block number #{block_id}." }

        block_json = client.get_block(block_id)

        next if block_json.blank? || block_json['transactions'].blank?

        deposits    = build_deposits(block_json)
        withdrawals = build_withdrawals(block_json)

        deposits.map { |d| d[:txid] }.join(',').tap do |txids|
          Rails.logger.info { "Deposit trancations in block #{block_id}: #{txids}" }
        end

        withdrawals.map { |w| w[:txid] }.join(',').tap do |txids|
          Rails.logger.info { "Withdraw trancations in block #{block_id}: #{txids}" }
        end
        update_or_create_deposits!(deposits)
        update_withdrawals!(withdrawals)

        # Mark block as processed if both deposits and withdrawals were confirmed.
        blockchain.update(height: block_id) if latest_block - block_id > blockchain.min_confirmations

        Rails.logger.info { "Finished processing #{blockchain.key} block number #{block_id}." }
      rescue => e
        report_exception(e)
      end
    end

    private

    def build_deposits(block_json)
      block_json
        .fetch('transactions')
        .each_with_object([]) do |tx, deposits|
          next if client.invalid_transaction?(tx)

          payment_addresses_where(address: client.to_address(tx)) do |payment_address|
            # If payment address currency doesn't match with blockchain
            # transaction currency skip this payment address.
            next if payment_address.currency.code.eth? != client.is_eth_tx?(tx)

            @client
              .build_transaction(tx, block_json, payment_address.currency)
              .tap do |deposit_tx|
              deposits << { txid:           deposit_tx[:id],
                            address:        deposit_tx[:to],
                            amount:         deposit_tx[:amount],
                            member:         payment_address.account.member,
                            currency:       payment_address.currency,
                            txout:          0,
                            block_number:   deposit_tx[:block_number] }
            end
          end
        end
    end

    def build_withdrawals(block_json)
      block_json
        .fetch('transactions')
        .each_with_object([]) do |tx, withdrawals|
          next if client.invalid_transaction?(tx)

          wallets_where(address: client.from_address(tx)) do |wallet|
            # If wallet currency doesn't match with blockchain transaction
            # currency skip this wallet.
            next if wallet.currency.code.eth? != client.is_eth_tx?(tx)

            @client
              .build_transaction(tx, block_json, wallet.currency)
              .tap do |withdraw_tx|
              withdrawals << { txid:           withdraw_tx[:id],
                               rid:            withdraw_tx[:to],
                               sum:            withdraw_tx[:amount],
                               block_number:   withdraw_tx[:block_number] }
            end
          end
        end
    end
  end
end

