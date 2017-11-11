class CoinRPC
  class XRP < self
    def handle(name, *args)
      post_body = { method: name, params: args }.to_json
      resp = JSON.parse( http_post_request(post_body) )
      raise JSONRPCError, resp['error'] if resp['error']
      result = resp['result']
      result.symbolize_keys! if result.is_a? Hash
      result
    end

    def http_post_request(post_body)
      http    = Net::HTTP.new(@uri.host, @uri.port)
      request = Net::HTTP::Post.new(@uri.request_uri)
      request.basic_auth @uri.user, @uri.password
      request.content_type = 'application/json'
      request.body = post_body
      http.request(request).body
    rescue Errno::ECONNREFUSED => e
      raise ConnectionRefusedError
    end

    def getbalance
      post_body = {
        method: 'account_info',
        params: [
          account: Currency.find_by_code('xrp').assets['accounts'][0]['address'],
          strict: true,
          ledger_index: 'validated'
        ]
      }.to_json

      resp = JSON.parse( http_post_request(post_body) )
      raise JSONRPCError, resp['error'] if resp['error']
      result = resp['result']['account_data']['Balance'].to_f / 1_000_000
      p result
      result
    end

    # def getnewaddress
    #   {
    #     "method": "wallet_propose",
    #     "params": [
    #         {
    #             "passphrase": "changeme"
    #         }
    #     ]
    #   }
    # end

    def safe_getbalance
      begin
        getbalance
      rescue
        'N/A'
      end
    end
  end
end
