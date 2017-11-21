module Auth0
  module ManagementAPI
    module Token

      def token
        if token_properties.blank? || token_expires_soon?
          self.token_properties = request_new_token
        end
        token_properties.fetch('access_token')
      end

    private

      attr_accessor :token_properties

      def token_expires_soon?
        token_properties.fetch('expires_at').to_f < (Time.current.to_f * 0.8)
      end

      def request_new_token
        Rails.logger.debug { 'Requesting new token for Auth0 Management API.' }
        response = Faraday.post 'https://' + ENV.fetch('AUTH0_DOMAIN') + '/oauth/token' do |request|
          request.body = { grant_type:    'client_credentials',
                           client_id:     ENV.fetch('AUTH0_MANAGEMENT_API_CLIENT_ID'),
                           client_secret: ENV.fetch('AUTH0_MANAGEMENT_API_CLIENT_SECRET'),
                           audience:      'https://' + ENV.fetch('AUTH0_DOMAIN') + '/api/v2/' }.to_json
          request.headers.update('Content-Type': 'application/json')
        end.assert_ok!

        JSON.parse(response.body).tap do |json|
          json['expires_at'] = Time.current + json.fetch('expires_in').seconds
        end
      end
    end
  end
end
