module WalletClient
  class Geth < Base

    TOKEN_METHOD_ID = '0xa9059cbb'

    def initialize(*)
      super
      @json_rpc_call_id  = 0
      @json_rpc_endpoint = URI.parse(wallet.gateway.dig('options','uri'))
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
        .map{|ad| currency.code.eth? ? load_balance_of_eth_address(ad) : load_balance_of_erc20_address(ad, currency)}
        .reduce(&:+).yield_self { |total| total ? convert_from_base_unit(total, currency) : 0.to_d }
    end


    def create_eth_withdrawal!(issuer, recipient, amount, currency, options = {})
      permit_transaction(issuer, recipient, currency)
      json_rpc(
          :eth_sendTransaction,
          [{
               from:  normalize_address(issuer.fetch(:address)),
               to:    normalize_address(recipient.fetch(:address)),
               value: '0x' + convert_to_base_unit!(amount, currency).to_s(16),
               gas:   options.key?(:gas_limit) ? '0x' + options[:gas_limit].to_s(16) : nil
           }.compact]
      ).fetch('result').yield_self do |txid|
        raise WalletClient::Error, \
          "#{currency.code.upcase} withdrawal from #{normalize_address(issuer[:address])} to #{normalize_address(recipient[:address])} failed." \
            unless valid_txid?(normalize_txid(txid))
        normalize_txid(txid)
      end
    end

    def create_erc20_withdrawal!(issuer, recipient, amount, currency, options = {})
      permit_transaction(issuer, recipient, currency)

      data = abi_encode \
        'transfer(address,uint256)',
        normalize_address(recipient.fetch(:address)),
        '0x' + convert_to_base_unit!(amount, currency).to_s(16)

      json_rpc(
          :eth_sendTransaction,
          [{
               from: normalize_address(issuer.fetch(:address)),
               to:   contract_address(currency),
               data: data
           }]
      ).fetch('result').yield_self do |txid|
        raise WalletClient::Error, \
          "#{currency.code.upcase} withdrawal from #{issuer[:address]} to #{recipient[:address]} failed." \
            unless valid_txid?(normalize_txid(txid))
        normalize_txid(txid)
      end
    end


    def normalize_address(address)
      address.downcase
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

    def load_balance_of_eth_address(address)
      json_rpc(:eth_getBalance, [normalize_address(address), 'latest']).fetch('result').hex.to_d
    rescue => e
      report_exception_to_screen(e)
      0.0
    end

    def load_balance_of_erc20_address(address, currency)
      data = abi_encode('balanceOf(address)', normalize_address(address))
      json_rpc(:eth_call, [{ to: contract_address(currency), data: data }, 'latest']).fetch('result').hex.to_d
    rescue => e
      report_exception_to_screen(e)
      0.0
    end

    def abi_encode(method, *args)
      '0x' + args.each_with_object(Digest::SHA3.hexdigest(method, 256)[0...8]) do |arg, data|
        data.concat(arg.gsub(/\A0x/, '').rjust(64, '0'))
      end
    end

    def permit_transaction(issuer, recipient, currency)
      json_rpc(:personal_unlockAccount, [normalize_address(issuer.fetch(:address)), issuer.fetch(:secret), 5]).tap do |response|
        unless response['result']
          raise WalletClient::Error, \
            "#{currency.code.upcase} withdrawal from #{normalize_address(issuer[:address])} to #{normalize_address(recipient[:address])} is not permitted."
        end
      end
    end

    def valid_address?(address)
      address.to_s.match?(/\A0x[A-F0-9]{40}\z/i)
    end

    def valid_txid?(txid)
      txid.to_s.match?(/\A0x[A-F0-9]{64}\z/i)
    end

    def contract_address(currency)
      normalize_address(currency.erc20_contract_address)
    end

  end
end
