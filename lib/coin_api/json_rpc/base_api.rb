# frozen_string_literal: true

module CoinAPI
  module JsonRPC
    class BaseAPI < ::CoinAPI::BaseAPI
      attr_accessor :json_rpc_endpoint
      protected     :json_rpc_endpoint

      def initialize(*)
        super

        self.json_rpc_endpoint = URI.parse(currency.json_rpc_endpoint)
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

      def json_rpc_params(_method, *_params)
        method_not_implemented
      end
    end
  end
end
