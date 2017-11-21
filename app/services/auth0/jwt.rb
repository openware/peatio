require 'openssl/x509'

module Auth0
  module JWT
    class << self
      def verify!(token, options = {})
        options.reverse_merge! \
          algorithm:         ENV.fetch('AUTH0_CLIENT_ALGORITHM', 'RS256'),
          aud:               ENV.fetch('AUTH0_CLIENT_ID'),
          verify_aud:        true,
          exp:               ENV.fetch('AUTH0_CLIENT_EXPIRATION', 36_000).to_i,
          verify_expiration: true

        ::JWT.decode(token, nil, true, options) { |header| jwks_hash[header.fetch('kid')] }
      rescue ::JWT::DecodeError, ::JWT::ExpiredSignature => e
        raise Auth0::BadTokenError, e.inspect
      end

    private

      def jwks_hash
        response  = Faraday.get('https://' + ENV.fetch('AUTH0_DOMAIN') + '/.well-known/jwks.json').assert_ok!
        jwks_keys = Array.wrap(JSON.parse(response.body).fetch('keys'))

        jwks_keys.each_with_object({}) do |k, memo|
          memo[k.fetch('kid')] = OpenSSL::X509::Certificate.new(Base64.decode64(k.fetch('x5c').first)).public_key
        end
      end
    end
  end
end
