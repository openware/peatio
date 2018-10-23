# encoding: UTF-8
# frozen_string_literal: true

module BlockchainClient
  class Wcg < Nxt
    def initialize(*)
      super
      @json_rpc_call_id  = 0
      @json_rpc_endpoint = URI.parse(blockchain.server + "/wcg?")
    end


    def valid_transaction?(tx, currency)
      # ( 0 = coin transfer; 5 = currency transfer; 2 = asset transfer)
      result = tx.has_key?('recipientRS') && [0, 5, 2].include?(tx['type'])
      result = (tx['type'] == 0 ? (convert_from_base_unit(tx['amountNQT'], currency) >= 0.1) : result)

      # check subType i.e 3 = currency transfer
      result = tx['type'] == 5 ? [3].include?(tx['subtype']) : result

      # check subType i.e 1 = asset transfer
      tx['type'] == 2 ? [1].include?(tx['subtype']) : result
    end

    protected

    def build_coin_transaction(tx, current_block, currency)
      entries = [
          {
              amount:  convert_from_base_unit(tx.fetch('amountNQT'), currency),
              address: normalize_address(tx['recipientRS'])
          }
      ]
      entries = []  unless currency.code.wcg?
      { id:            normalize_txid(tx.fetch('transaction')),
        block_number:  current_block,
        entries: entries
      }
    end
  end
end
