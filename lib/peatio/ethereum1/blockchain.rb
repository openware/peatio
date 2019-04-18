module Ethereum1
  class Blockchain < Peatio::Blockchain::Abstract

    class MissingSettingError < StandardError
      def initialize(key = '')
        super "#{key.capitalize} setting is missing"
      end
    end

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
      supported_settings[:currencies].each do |c|
        if c.dig(:options, :erc20_contract_address).present?
          @erc20 << c
        else
          @eth << c
        end
      end if supported_settings[:currencies]
      @settings.merge!(supported_settings)
    end

    def fetch_block!(block_number)
      block_json = client.json_rpc(:eth_getBlockByNumber, ["0x#{block_number.to_s(16)}", true])

      if block_json.blank? || block_json['transactions'].blank?
        Rails.logger.info { "Skipped processing #{block_number}" }
        return
      end

      block_json.fetch('transactions').each_with_object([]) do |tx, block_arr|
        if tx.fetch('input').hex <= 0
          next if invalid_eth_transaction?(tx)
        else
          tx = client.json_rpc(:eth_getTransactionReceipt, [normalize_txid(tx.fetch('hash'))])
          next if tx.nil? || invalid_erc20_transaction?(tx)
        end

        txs = build_transactions(tx).map do |ntx|
          Peatio::Transaction.new(ntx.merge(block_number: block_number))
        end

        block_arr.append(*txs)
      end.yield_self { |block_arr| Peatio::Block.new(block_number, block_arr) }
    end

    def latest_block_number
      client.json_rpc(:eth_blockNumber)
    end

    # @deprecated
    def supports_cash_addr_format?
      @features[:supports_cash_addr_format]
    end

    private

    def client
      @client ||= Ethereum1::Client.new(settings_fetch(:server))
    end

    def settings_fetch(key)
      @settings.fetch(key) { raise MissingSettingError(key.to_s) }
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

    def build_eth_transactions(tx)
      @eth.each_with_object([]) do |currency, formatted_txs|
        formatted_txs << { hash:        normalize_txid(tx.fetch('hash')),
                           amount:      convert_from_base_unit(tx.fetch('value').hex, currency), 
                           to_address:  normalize_address(tx['to']),
                           txout:       (tx.fetch('transactionIndex').to_i 16),
                           currency_id: currency.fetch(:id) }
      end
    end

    def build_erc20_transactions(tx)
      tx.fetch('logs').each_with_object([]) do |log, formatted_txs|

        next if log.fetch('topics').blank? || log.fetch('topics')[0] != TOKEN_EVENT_IDENTIFIER

        # Skip if ERC20 contract address doesn't match.
        currencies = @erc20.select { |c| c.dig(:options, :erc20_contract_address) == log.fetch('address') }
        next unless currencies.present?

        destination_address = normalize_address('0x' + log.fetch('topics').last[-40..-1])

        currencies.each do |currency|
          formatted_txs << { hash:        normalize_txid(tx.fetch('transactionHash')),
                             amount:      convert_from_base_unit(log.fetch('data').hex, currency),
                             to_address:  destination_address,
                             txout:       log['logIndex'].to_i(16),
                             currency_id: currency.fetch(:id) }
        end
      end
    end

    def invalid_eth_transaction?(block_txn)
      block_txn.fetch('to').blank? \
      || block_txn.fetch('value').hex.to_d <= 0 && block_txn.fetch('input').hex <= 0 \
    end

    def invalid_erc20_transaction?(txn_receipt)
      txn_receipt.fetch('status') != SUCCESS \
      || txn_receipt.fetch('to').blank? \
      || txn_receipt.fetch('logs').blank?
    end

    def convert_from_base_unit(value, currency)
      value.to_d / currency.fetch(:base_factor).to_d
    end
  end
end
