# frozen_string_literal: true

module CoinAPI
  class ETH < BaseAPI
    attr_accessor :json_rpc_endpoint, :request_id
    protected     :json_rpc_endpoint, :request_id

    def initialize(*)
      super

      self.json_rpc_endpoint = URI.parse(currency.json_rpc_endpoint)
      self.request_id = 0
    end

    delegate :precision, to: :currency

    def load_balance!
      do_request(:eth_getBalance, hot_wallet_address, 'latest').hex.to_f / 10 ** precision
    end

    protected

    def connection
      Faraday.new(json_rpc_endpoint).tap do |connection|
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
  end
end
