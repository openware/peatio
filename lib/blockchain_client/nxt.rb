# encoding: UTF-8
# frozen_string_literal: true

module BlockchainClient
  class Nxt < Base
    def initialize(*)
      super
      @json_rpc_call_id  = 0
      @json_rpc_endpoint = URI.parse(blockchain.server + "/nxt?")
    end

    def endpoint
      @json_rpc_endpoint
    end

    def latest_block_number
      Rails.cache.fetch "latest_#{self.class.name.underscore}_block_number", expires_in: 5.seconds do
        json_rpc({requestType: 'getBlocks', lastIndex: 0}).fetch('blocks')[0].fetch('height')
      end
    end

    def get_block(block_hash)
      json_rpc({requestType: 'getBlock', block: block_hash, includeTransactions: true})
    end

    def get_block_hash(height)
      current_block   = height || 0
      json_rpc({requestType: 'getBlockId', height: current_block}).fetch('block')
    end

    def get_unconfirmed_txns
      json_rpc({ requestType: 'getUnconfirmedTransactions'}).fetch('unconfirmedTransactions')
    end

    def get_raw_transaction(txid)
      json_rpc({ requestType: 'getTransaction', transaction: txid})
    end

    def build_transaction(tx, current_block, currency)
      if tx['type'] == 2
        build_asset_transaction(tx, current_block, currency)
      elsif tx['type'] == 5
        build_currency_transaction(tx, current_block, currency)
      else
        build_coin_transaction(tx, current_block, currency)
      end
    end

    def to_address(tx)
      [normalize_address(tx.fetch('recipientRS'))]
    end

    def valid_transaction?(tx, nxt_currency)
      # ( 0 = coin transfer; 5 = currency transfer; 2 = asset transfer)
      result = tx.has_key?('recipientRS') && [0, 5, 2].include?(tx['type'])
      result = (tx['type'] == 0 ? (convert_from_base_unit(tx['amountNQT'], nxt_currency) > 1) : result)

      # check subType i.e 3 = currency transfer
      result = tx['type'] == 5 ? [3].include?(tx['subtype']) : result

      # check subType i.e 1 = asset transfer
      tx['type'] == 2 ? [1].include?(tx['subtype']) : result
    end

    def invalid_transaction?(tx, nxt_currency)
      !valid_transaction?(tx, nxt_currency)
    end

  protected

    def connection
      Faraday.new(@json_rpc_endpoint).tap do |connection|
        unless @json_rpc_endpoint.user.blank?
          connection.basic_auth(@json_rpc_endpoint.user, @json_rpc_endpoint.password)
        end
      end
    end
    memoize :connection

    def json_rpc(params = {})
      response = connection.post do |req|
        req.body = params
      end
      response.assert_success!
      response = JSON.parse(response.body)
      response['errorDescription'].tap { |error| raise Error, error.inspect if error }
      response
    end

    def build_coin_transaction(tx, current_block, currency)
      entries = [
          {
              amount:  convert_from_base_unit(tx.fetch('amountNQT'), currency),
              address: normalize_address(tx['recipientRS'])
          }
      ]
      entries = []  unless currency.code.nxt?
      { id:            normalize_txid(tx.fetch('transaction')),
        block_number:  current_block,
        entries: entries
      }
    end

    def build_currency_transaction(tx, current_block, currency)
      entries = [
          {
              amount:  convert_from_base_unit(tx['attachment']['units'], currency),
              address: normalize_address(tx['recipientRS'])
          }
      ]
      entries = []  if currency.nxt_currency_id != tx['attachment']['currency']
      { id:            normalize_txid(tx.fetch('transaction')),
        block_number:  current_block,
        entries: entries
      }
    end

    def build_asset_transaction(tx, current_block, currency)
      entries = [
          {
              amount:  convert_from_base_unit(tx['attachment']['quantityQNT'], currency),
              address: normalize_address(tx['recipientRS'])
          }
      ]
      entries = []  if currency.nxt_asset_id != tx['attachment']['asset']
      { id:            normalize_txid(tx.fetch('transaction')),
        block_number:  current_block,
        entries: entries
      }
    end
  end
end
