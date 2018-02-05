# frozen_string_literal: true

module CoinAPI
  class ERC20 < ETH
    ADDRESS_REGEXP = /\A0x[a-fA-F0-9]{40}\z/
    TRANSFER_IDENTIFIER = '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef'
    SUCCESS_STATUS = '0x1'
    private_constant :ADDRESS_REGEXP, :TRANSFER_IDENTIFIER, :SUCCESS_STATUS

    attr_accessor :current_address
    private       :current_address

    def initialize(*)
      super

      self.current_address = eth_coinbase
    end

    delegate :token_address, to: :currency
    delegate :to_address,
             :to_hex,
             :with_lead_zero,
             :from_address,
             :to_float_with_precision,
             :to_int,
             to: :formatter

    def load_balance!
      data = build_data('balanceOf(address)', current_address)

      do_request(:eth_call, {to: token_address, data: data}, 'latest').yield_self do |result|
        to_float_with_precision(result)
      end
    end

    def load_deposit!(txid)
      do_request(:eth_getTransactionReceipt, txid).yield_self { |tx| build_standalone_deposit(tx) }
    end

    def inspect_address!(address)
      {
        address: address,
        is_valid: ADDRESS_REGEXP.match?(address),
        is_mine: address == current_address
      }
    end

    def create_withdrawal!(_issuer, recipient, amount, fee)
      data = build_data(
        'transfer(address,uint256)',
        recipient.fetch(:address),
        to_hex(amount)
      )

      do_request(
        :eth_sendTransaction,
        from: current_address,
        to: token_address,
        data: data,
        gas: with_lead_zero(to_hex(fee))
      )
    end

    def each_deposit!
      each_batch_of_deposits.each { |deposit| yield deposit }
    end

    def each_deposit
      each_batch_of_deposits(false).each { |deposit| yield deposit }
    end

    private

    def build_data(method, *args)
      args.each_with_object(method_identifier(method).dup) do |arg, data|
        data.concat(arg.gsub(/^0x/, '').rjust(64, '0'))
      end
    end

    def eth_call(*params)
      do_request(:eth_call, *params)
    end

    def method_identifier(method)
      with_lead_zero(Digest::SHA3.hexdigest(method, 256)[0..7])
    end

    def build_standalone_deposit(tx)
      return {} unless tx['status'] == SUCCESS_STATUS

      entries = tx['logs'].each_with_object([]) do |log, result|
        next unless log['topics'].first == TRANSFER_IDENTIFIER
        next unless from_address(log['topics'].last).casecmp(current_address).zero?

        result << {
          amount: to_float_with_precision(log['data']),
          address: from_address(log['topics'].second)
        }
      end

      {
        id: tx.fetch('transactionHash'),
        confirmations: calculate_confirmations(to_int(tx.fetch('blockNumber'))),
        entries: entries
      }
    end

    def build_deposit_collection(tx)
      {
        id: tx.fetch('transactionHash'),
        confirmations: calculate_confirmations(to_int(tx.fetch('blockNumber'))),
        entries: [
          {
            amount: to_float_with_precision(tx['data']),
            address: from_address(tx['topics'].second)
          }
        ]
      }
    end

    def each_batch_of_deposits(raise = true)
      fetch_logs.map(&method(:build_deposit_collection))
    rescue StandardError => e
      report_exception(e)

      raise e if raise
    end

    def fetch_logs
      do_request(
        :eth_getLogs,
        address: token_address,
        topics: [TRANSFER_IDENTIFIER, nil, to_address(current_address)],
        fromBlock: 'earliest',
        toBlock: 'latest'
      )
    end

    def calculate_confirmations(block_number)
      return 0 unless block_number.present?

      current_block_number - block_number
    end

    def current_block_number
      to_int(do_request(:eth_blockNumber))
    end
    memoize :current_block_number
  end
end
