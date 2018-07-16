# encoding: UTF-8
# frozen_string_literal: true

module Client
  class Ethereum < Base

    TOKEN_METHOD_ID = '0xa9059cbb'

    def initialize(*)
      super
      @json_rpc_call_id  = 0
      @json_rpc_endpoint = URI.parse(blockchain.server)
    end

    def endpoint
      @json_rpc_endpoint
    end

    def create_address!(options = {})
      secret = options.fetch(:secret) { Passgen.generate(length: 64, symbols: true) }
      secret.yield_self do |password|
        { address: normalize_address(json_rpc(:personal_newAccount, [password]).fetch('result')),
          secret:  password }
      end
    end

    def load_balance!(currency)
      PaymentAddress
        .where(currency: currency)
        .where(PaymentAddress.arel_table[:address].is_not_blank)
        .pluck(:address)
        .reject(&:blank?)
        .map(&method(currency.code.eth? ? :load_balance_of_eth_address : :load_balance_of_erc20_address))
        .reduce(&:+).yield_self { |total| total ? convert_from_base_unit(total, currency) : 0.to_d }
    end

    def inspect_address!(address)
      { address:  normalize_address(address),
        is_valid: valid_address?(normalize_address(address)) }
    end

    def get_block(height)
      current_block   = height || 0
      json_rpc(:eth_getBlockByNumber, ["0x#{current_block.to_s(16)}", true]).fetch('result')
    end

    def to_address(tx)
      if is_eth_tx?(tx)
        normalize_address(tx['to'])
      else
        normalize_address('0x' + abi_explode(tx['input'])[:arguments][0][26..-1])
      end
    end

    def build_deposit(tx, current_block, latest_block, currency)
      if is_eth_tx?(tx)
        build_eth_deposit(tx, current_block, latest_block, currency)
      else
        build_erc20_deposit(tx, current_block, latest_block, currency)
      end
    end

    def latest_block_number
      Rails.cache.fetch :latest_ethereum_block_number, expires_in: 5.seconds do
        json_rpc(:eth_blockNumber).fetch('result').hex
      end
    end

    def invalid_transaction?(tx)
      tx['to'].blank? \
      || tx.fetch('value').hex.to_d <= 0 && tx['input'].hex <= 0 \
      || tx['input'].hex > 0 && abi_method(tx['input']) != TOKEN_METHOD_ID
    end

    def valid_transaction?(tx)
      !invalid_transaction?(tx)
    end

    def is_eth_tx?(tx)
      tx['input'].blank? || tx['input'].hex <= 0
    end

    def is_erc20_tx?(tx)
      !is_eth_tx?(tx)
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
        { jsonrpc: '2.0', id: @json_rpc_call_id += 1, method: method, params: params }.to_json,
        { 'Accept'       => 'application/json',
          'Content-Type' => 'application/json' }
      response.assert_success!
      response = JSON.parse(response.body)
      response['error'].tap { |error| raise Error, error.inspect if error }
      response
    end


    def block_information(number)
      json_rpc(:eth_getBlockByNumber, [number, false]).fetch('result')
    end

    def permit_transaction(issuer, recipient)
      json_rpc(:personal_unlockAccount, [normalize_address(issuer.fetch(:address)), issuer.fetch(:secret), 5]).tap do |response|
        unless response['result']
          raise CoinAPI::Error, \
            "#{currency.code.upcase} withdrawal from #{normalize_address(issuer[:address])} to #{normalize_address(recipient[:address])} is not permitted."
        end
      end
    end

    def load_balance_of_eth_address(address)
      json_rpc(:eth_getBalance, [normalize_address(address), 'latest']).fetch('result').hex.to_d
    rescue => e
      report_exception_to_screen(e)
      0.0
    end

    def load_balance_of_erc20_address(address)
      data = abi_encode('balanceOf(address)', normalize_address(address))
      json_rpc(:eth_call, [{ to: contract_address, data: data }, 'latest']).fetch('result').hex.to_d
    rescue => e
      report_exception_to_screen(e)
      0.0
    end

    def abi_encode(method, *args)
      '0x' + args.each_with_object(Digest::SHA3.hexdigest(method, 256)[0...8]) do |arg, data|
        data.concat(arg.gsub(/\A0x/, '').rjust(64, '0'))
      end
    end

    def abi_explode(data)
      data = data.gsub(/\A0x/, '')
      { method:    '0x' + data[0...8],
        arguments: data[8..-1].chars.in_groups_of(64, false).map { |group| '0x' + group.join } }
    end

    def abi_method(data)
      '0x' + data.gsub(/\A0x/, '')[0...8]
    end

    def valid_address?(address)
      address.to_s.match?(/\A0x[A-F0-9]{40}\z/i)
    end

    def valid_txid?(txid)
      txid.to_s.match?(/\A0x[A-F0-9]{64}\z/i)
    end

    def build_eth_deposit(tx, current_block, latest_block, currency)
      { id:            normalize_txid(tx.fetch('hash')),
        confirmations: latest_block - current_block.fetch('number').hex,
        received_at:   Time.at(current_block.fetch('timestamp').hex),
        entries:       [{ amount:  convert_from_base_unit(tx.fetch('value').hex, currency),
                          address: normalize_address(tx['to']) }] }
    end

    def build_erc20_deposit(tx, current_block, latest_block, currency)
      arguments = abi_explode(tx['input'])[:arguments]

      { id:            normalize_txid(tx.fetch('hash')),
        confirmations: latest_block - current_block.fetch('number').hex,
        received_at:   Time.at(current_block.fetch('timestamp').hex),
        entries:       [{ amount:  convert_from_base_unit(arguments[1].hex, currency),
                          address: normalize_address('0x' + arguments[0][26..-1]) }] }
    end

    def contract_address
      normalize_address(currency.erc20_contract_address)
    end
  end
end
