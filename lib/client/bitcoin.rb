# encoding: UTF-8
# frozen_string_literal: true

module Client
  class Bitcoin < Base
    def initialize(*)
      super
      @json_rpc_call_id  = 0
      @json_rpc_endpoint = URI.parse(blockchain.server)
    end

    def endpoint
      @json_rpc_endpoint
    end
    def load_balance!
      json_rpc(:getbalance).fetch('result').to_d
    end

    def each_deposit!(options = {})
      each_batch_of_deposits do |deposits|
        deposits.each { |deposit| yield deposit if block_given? }
      end
    end

    def each_deposit(options = {})
      each_batch_of_deposits false do |deposits|
        deposits.each { |deposit| yield deposit if block_given? }
      end
    end

    def load_deposit!(txid)
      json_rpc(:gettransaction, [normalize_txid(txid)]).fetch('result').yield_self { |tx| build_standalone_deposit(tx) }
    end

    def create_address!(options = {})
      { address: normalize_address(json_rpc(:getnewaddress).fetch('result')) }
    end

    def create_withdrawal!(issuer, recipient, amount, options = {})
      json_rpc(:settxfee, [options[:fee]]) if options.key?(:fee)
      json_rpc(:sendtoaddress, [normalize_address(recipient.fetch(:address)), amount])
        .fetch('result')
        .yield_self(&method(:normalize_txid))
    end

    def inspect_address!(address)
      json_rpc(:validateaddress, [normalize_address(address)]).fetch('result').yield_self do |x|
        { address: normalize_address(address), is_valid: !!x['isvalid'] }
      end
    end

    def latest_block_number
      Rails.cache.fetch :latest_bitcoin_block_number, expires_in: 5.seconds do
        json_rpc(:getblockcount).fetch('result')
      end
    end

    def get_block(block_hash)
      json_rpc(:getblock, [block_hash, 2]).fetch('result')
    end

    def get_block_hash(height)
      current_block   = height || 0
      json_rpc(:getblockhash, [current_block]).fetch('result')
    end

    def to_address(tx)
      tx.fetch("vout").map{|v| v["scriptPubKey"]["addresses"][0] if v["scriptPubKey"].has_key?("addresses")}.compact
    end

    def build_transaction(tx, current_block, latest_block, address)
      entries = tx.fetch('vout').map do |item|

        next if item.fetch('value').to_d <= 0
        next unless item["scriptPubKey"].has_key?("addresses")
        next if address != item['scriptPubKey']['addresses'][0]

        { amount: item.fetch('value').to_d, address: normalize_address(item['scriptPubKey']['addresses'][0]) }
      end.compact
      { id:            normalize_txid(tx.fetch('txid')),
        confirmations: latest_block - current_block,
        entries:       entries }
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

    def json_rpc(method, params = [])
      response = connection.post \
        '/',
        { jsonrpc: '1.0', method: method, params: params }.to_json,
        { 'Accept'       => 'application/json',
          'Content-Type' => 'application/json' }
      response.assert_success!
      response = JSON.parse(response.body)
      response['error'].tap { |error| raise Error, error.inspect if error }
      response
    end

    def each_batch_of_deposits(raise = true)
      offset    = 0
      collected = []
      loop do
        begin
          batch_deposits = nil
          response       = json_rpc(:listtransactions, ['*', 100, offset])
          offset        += 100
          batch_deposits = build_deposit_collection(response.fetch('result'))
        rescue => e
          report_exception(e)
          raise e if raise
        end
        yield batch_deposits if batch_deposits
        collected += batch_deposits
        break unless more_deposits_available?(batch_deposits)
      end
      collected
    end

    def build_standalone_deposit(tx)
      entries = tx.fetch('details').map do |item|
        next unless item.fetch('category') == 'receive'
        { amount: item.fetch('amount').to_d, address: normalize_address(item.fetch('address')) }
      end.compact
      { id:            normalize_txid(tx.fetch('txid')),
        confirmations: tx.fetch('confirmations').to_i,
        received_at:   Time.at(tx.fetch('timereceived')),
        entries:       entries }
    end

    def build_deposit_collection(txs)
      txs.map do |tx|
        next unless tx.fetch('category') == 'receive'
        { id:            normalize_txid(tx.fetch('txid')),
          confirmations: tx.fetch('confirmations').to_i,
          received_at:   Time.at(tx.fetch('timereceived')),
          entries:       [{ amount: tx.fetch('amount').to_d, address: normalize_address(tx.fetch('address')) }] }
      end.compact.reverse
    end

    def more_deposits_available?(batch_deposits)
      batch_deposits.present?
    end
  end
end
