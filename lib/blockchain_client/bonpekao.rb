# encoding: UTF-8
# frozen_string_literal: true

module BlockchainClient
  class Bonpekao < Bitcoin

    def get_block(block_hash)
      json_rpc(:getblock, [block_hash, false]).fetch('result')
    end

    def get_raw_transaction(txid)
      json_rpc(:getrawtransaction, [txid, 1]).fetch('result')
    end

    def latest_block_number
      Rails.cache.fetch :latest_bitcoincash_block_number, expires_in: 5.seconds do
        json_rpc(:getblockcount).fetch('result')
      end
    end

  end
end
