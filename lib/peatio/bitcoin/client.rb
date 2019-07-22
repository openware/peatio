module Bitcoin
  class Client
    Error = Class.new(StandardError)

    class ConnectionError < Error; end

    class ServerError < Error
      attr_reader :wrapped_exception

      def initialize(exc)
        @wrapped_exception = exc
      end

      def backtrace
        if @wrapped_exception
          @wrapped_exception.backtrace
        else
          super
        end
      end
    end

    class ResponseError < Error
      def initialize(code, msg)
        @code = code
        @msg = msg
      end

      def message
        "#{@msg} (#{@code})"
      end
    end

    extend Memoist

    def initialize(endpoint, idle_timeout: 5)
      @json_rpc_endpoint = URI.parse(endpoint)
      @idle_timeout = idle_timeout
    end

    def json_rpc(method, params = [])
      response = connection.post \
        '/',
        {jsonrpc: '1.0', method: method, params: params}.to_json,
        {'Accept' => 'application/json',
         'Content-Type' => 'application/json'}
      response.assert_success!
      response = JSON.parse(response.body)
      response['error'].tap { |error| raise ResponseError.new(error['code'], error['message']) if error }
      response.fetch('result')
      # TODO: Rescue ServerError in daemons that provide ability to create blockchain transactions.
    rescue Faraday::TimeoutError => e
      raise ServerError, e
    rescue Faraday::Error => e
      raise ConnectionError => e
    rescue StandardError => e
      raise Error, e
    end

    private

    def connection
      @connection ||= Faraday.new(@json_rpc_endpoint) do |f|
        f.adapter :net_http_persistent, pool_size: 5, idle_timeout: @idle_timeout
      end.tap do |connection|
        unless @json_rpc_endpoint.user.blank?
          connection.basic_auth(@json_rpc_endpoint.user, @json_rpc_endpoint.password)
        end
      end
    end
  end
end
