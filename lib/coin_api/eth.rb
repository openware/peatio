# frozen_string_literal: true

module CoinAPI
  class ETH < BaseAPI
    class Formatter
      attr_accessor :currency
      private       :currency

      def initialize(currency)
        self.currency = currency
      end

      def from_input(hexstring)
        hexstring[10..-1].scan(/.{64}/)
      end

      def from_address(hexstring)
        with_lead_zero(hexstring[-40..-1])
      end

      def to_int(hexstring)
        return nil if hexstring.nil?

        hexstring.gsub(/^0x/, '')[0..1] == 'ff' ? (hexstring.hex - (2**256)) : hexstring.hex
      end

      def to_float(hexstring)
        return nil if hexstring.nil?

        to_int(hexstring).to_f
      end

      def to_float_with_precision(hexstring)
        return nil if hexstring.nil?

        to_float(hexstring) / (10**currency.precision)
      end

      def to_hex(value)
        value.to_s(16)
      end

      def to_address(address)
        with_lead_zero(address.gsub(/^0x/, '').rjust(64, '0'))
      end

      def with_lead_zero(value)
        "0x#{value}"
      end
    end
    private_constant :Formatter

    attr_accessor :json_rpc_endpoint, :request_id
    protected     :json_rpc_endpoint, :request_id

    def initialize(*)
      super

      self.json_rpc_endpoint = URI.parse(currency.json_rpc_endpoint)
      self.request_id = 0
    end

    def load_balance!
      do_request(:eth_getBalance, hot_wallet_address, 'latest').yield_self do |result|
        formatter.to_float_with_precision(result)
      end
    end

    #
    # Creates address and generates password
    #
    # @return {address: aaa, secret: bbb}
    def create_address!
      pass = SecureRandom.base64(15)
      res = do_request(:personal_newAccount, pass)
      {address: res, secret: pass}
    end

    protected

    def eth_coinbase
      do_request(:eth_coinbase)
    end

    def connection
      Faraday.new(json_rpc_endpoint).tap do |connection|
        connection.options[:open_timeout] = 2
        connection.options[:timeout] = 5

        unless json_rpc_endpoint.user.blank?
          connection.basic_auth(json_rpc_endpoint.user, json_rpc_endpoint.password)
        end
      end
    end
    memoize :connection

    def do_request(method, *params)
      response = connection.post(
        '/',
        json_rpc_params(method, *params).to_json,
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      )

      response.assert_success!
      response = JSON.parse(response.body)
      response['error'].tap { |error| raise Error, error.inspect if error }
      response.fetch('result')
    end

    def json_rpc_params(method, *params)
      {
        jsonrpc: '2.0',
        method: method,
        params: params,
        id: increment_request_id!
      }
    end

    def increment_request_id!
      self.request_id += 1
    end

    def formatter
      Formatter.new(currency)
    end
    memoize :formatter
  end
end
