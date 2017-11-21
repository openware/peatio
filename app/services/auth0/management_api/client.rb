# frozen_string_literal: true

require 'cgi'

module Auth0
  module ManagementAPI
    class Client
      def initialize(token = ManagementAPI.token)
        @token = token
      end

      def user(id)
        response = Faraday.get "#{endpoint}/api/v2/users/#{CGI.escape(id)}" do |request|
          request.headers.update(Authorization: "Bearer #{@token}")
        end.assert_ok!
        JSON.parse(response.body)
      end

    private

      def endpoint
        "https://#{ENV.fetch('AUTH0_DOMAIN')}"
      end
    end
  end
end
