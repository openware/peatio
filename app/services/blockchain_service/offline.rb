# encoding: UTF-8
# frozen_string_literal: true

module BlockchainService
  class Offline < Base
    def process_blockchain(blocks_limit: 100, force: false)
      block, latest_block_number = super

      ActiveRecord::Base.transaction do
        update_or_create_deposits!(block[:deposits])
      end
      # save_block(block_data, latest_ledger)
    end
  end
end