module Ethereum1
  class Blockchain < Peatio::Blockchain::Abstract

    TOKEN_EVENT_IDENTIFIER = '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef'
    SUCCESS = '0x1'

    DEFAULT_FEATURES = { case_sensitive: false, cash_addr_format: false }.freeze

    def initialize(custom_features = {})
      @features = DEFAULT_FEATURES.merge(custom_features).slice(*SUPPORTED_FEATURES)
      @settings = {}
    end

    def configure(settings = {})
      @erc20 = []; @eth = []
      supported_settings = settings.slice(*SUPPORTED_SETTINGS)
      supported_settings[:currencies]&.each do |c|
        if c.dig(:options, :erc20_contract_address).present?
          @erc20 << c
        else
          @eth << c
        end
      end
      @settings.merge!(supported_settings)
    end

    def fetch_block!(block_number)
      block_json = client.json_rpc(:eth_getBlockByNumber, ["0x#{block_number.to_s(16)}", true])

      if block_json.blank? || block_json['transactions'].blank?
        return Peatio::Block.new(block_number, [])
      end

      block_json.fetch('transactions').each_with_object([]) do |tx, block_arr|
        if tx.fetch('input').hex <= 0
          next if invalid_eth_transaction?(tx)
        else
          tx = client.json_rpc(:eth_getTransactionReceipt, [normalize_txid(tx.fetch('hash'))])
          next if tx.nil? || invalid_erc20_transaction?(tx)
        end

        txs = build_transactions(tx).map do |ntx|
          Peatio::Transaction.new(ntx)
        end

        block_arr.append(*txs)
      end.yield_self { |block_arr| Peatio::Block.new(block_number, block_arr) }
    rescue Ethereum1::Client::Error => e
      raise Peatio::Blockchain::ClientError, e
    end

    def latest_block_number
      client.json_rpc(:eth_blockNumber).to_i(16)
    rescue Ethereum1::Client::Error => e
      raise Peatio::Blockchain::ClientError, e
    end

    private

    def client
      @client ||= Ethereum1::Client.new(settings_fetch(:server))
    end

    def settings_fetch(key)
      @settings.fetch(key) { raise Peatio::Blockchain::MissingSettingError, key.to_s }
    end

    def normalize_txid(txid)
      txid.try(:downcase)
    end

    def normalize_address(address)
      address.try(:downcase)
    end

    def build_transactions(tx_hash)
      if tx_hash.has_key?('logs')
        build_erc20_transactions(tx_hash)
      else
        build_eth_transactions(tx_hash)
      end
    end

    def build_eth_transactions(block_txn)
      @eth.map do |currency|
        { hash:          normalize_txid(block_txn.fetch('hash')),
          amount:        convert_from_base_unit(block_txn.fetch('value').hex, currency),
          to_address:    normalize_address(block_txn['to']),
          txout:         block_txn.fetch('transactionIndex').to_i(16),
          block_number:  block_txn.fetch('blockNumber').to_i(16),
          currency_id:   currency.fetch(:id),
          status:        transaction_status(block_txn) }
      end
    end

    def build_erc20_transactions(txn_receipt)
      txn_receipt.fetch('logs').each_with_object([]) do |log, formatted_txs|

        next if log.fetch('topics').blank? || log.fetch('topics')[0] != TOKEN_EVENT_IDENTIFIER

        # Skip if ERC20 contract address doesn't match.
        currencies = @erc20.select { |c| c.dig(:options, :erc20_contract_address) == log.fetch('address') }
        next if currencies.blank?

        destination_address = normalize_address('0x' + log.fetch('topics').last[-40..-1])

        currencies.each do |currency|
          formatted_txs << { hash:         normalize_txid(txn_receipt.fetch('transactionHash')),
                             amount:       convert_from_base_unit(log.fetch('data').hex, currency),
                             to_address:   destination_address,
                             txout:        log['logIndex'].to_i(16),
                             block_number: txn_receipt.fetch('blockNumber').to_i(16),
                             currency_id:  currency.fetch(:id),
                             status:       transaction_status(txn_receipt) }
        end
      end
    end

    def transaction_status(block_txn)
      # TODO: Add fetching status for eth transaction
      block_txn.fetch('status', '0x1') == '0x1' ? 'success' : 'fail'
    end

    def invalid_eth_transaction?(block_txn)
      block_txn.fetch('to').blank? \
      || block_txn.fetch('value').hex.to_d <= 0 && block_txn.fetch('input').hex <= 0
    end

    def invalid_erc20_transaction?(txn_receipt)
      txn_receipt.fetch('to').blank? || txn_receipt.fetch('logs').blank?
    end

    def convert_from_base_unit(value, currency)
      value.to_d / currency.fetch(:base_factor).to_d
    end
  end
end
