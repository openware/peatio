module Bitcoin
  class Client
    def initialize(endpoint)
      @json_rpc_endpoint = URI.parse(endpoint)
    end
  end
end
