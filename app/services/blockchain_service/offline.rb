# encoding: UTF-8
# frozen_string_literal: true

module BlockchainService
  class Offline < Base
    def process_blockchain(blocks_limit: 100, force: false)
      return super

      save_block(block_data, latest_ledger)
    end
  end
end