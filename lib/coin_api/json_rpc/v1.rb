# frozen_string_literal: true

module CoinAPI
  module JsonRPC
    class V2 < ::CoinAPI::JsonRPC::BaseAPI
      JSON_RPC_VERION = '1.0'
      private_constant :JSON_RPC_VERION

      protected

      def json_rpc_params(method, *params)
        {
          jsonrpc: JSON_RPC_VERION,
          method: method,
          params: params
        }
      end
    end
  end
end
