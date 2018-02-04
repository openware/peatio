# frozen_string_literal: true

module CoinAPI
  module JsonRPC
    class V2 < ::CoinAPI::JsonRPC::BaseAPI
      JSON_RPC_VERION = '2.0'
      private_constant :JSON_RPC_VERION

      attr_accessor :request_id
      protected     :request_id

      def initialize(*)
        super

        self.request_id = 0
      end

      protected

      def json_rpc_params(method, *params)
        {
          jsonrpc: JSON_RPC_VERION,
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
end
