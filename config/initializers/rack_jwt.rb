require 'rack/jwt'

verify_options = {
  verify_expiration: true,
  verify_not_before: true,
  iss: ENV["JWT_ISSUER"],
  verify_iss: !ENV["JWT_ISSUER"].nil?,
  verify_iat: true,
  verify_jti: true,
  aud: ENV["JWT_AUDIENCE"].to_s.split(",").reject(&:empty?),
  verify_aud: !ENV["JWT_AUDIENCE"].nil?,
  sub: "session",
  verify_sub: true,
  algorithm: ENV["JWT_ALGORITHM"] || "RS256",
  leeway: ENV["JWT_DEFAULT_LEEWAY"].yield_self { |n| n.to_i unless n.nil? },
  iat_leeway: ENV["JWT_ISSUED_AT_LEEWAY"].yield_self { |n| n.to_i unless n.nil? },
  exp_leeway: ENV["JWT_EXPIRATION_LEEWAY"].yield_self { |n| n.to_i unless n.nil? },
  nbf_leeway: ENV["JWT_NOT_BEFORE_LEEWAY"].yield_self { |n| n.to_i unless n.nil? },
}.compact

on_error = lambda do |error|
  error_message = {
    ::JWT::DecodeError => 'Invalid JWT token : Decode Error',
    ::JWT::VerificationError => 'Invalid JWT token : Signature Verification Error',
    ::JWT::ExpiredSignature => 'Invalid JWT token : Expired Signature (exp)',
    ::JWT::IncorrectAlgorithm => 'Invalid JWT token : Incorrect Key Algorithm',
    ::JWT::ImmatureSignature => 'Invalid JWT token : Immature Signature (nbf)',
    ::JWT::InvalidIssuerError => 'Invalid JWT token : Invalid Issuer (iss)',
    ::JWT::InvalidIatError => 'Invalid JWT token : Invalid Issued At (iat)',
    ::JWT::InvalidAudError => 'Invalid JWT token : Invalid Audience (aud)',
    ::JWT::InvalidSubError => 'Invalid JWT token : Invalid Subject (sub)',
    ::JWT::InvalidJtiError => 'Invalid JWT token : Invalid JWT ID (jti)',
    ::JWT::InvalidPayload => 'Invalid JWT token : Invalid Payload',
    MissingAuthHeader => 'Missing Authorization header',
    InvalidAuthHeaderFormat => 'Invalid Authorization header format'
  }
  message = error_message.fetch(error.class, 'Default')
  body    = { error: message }.to_json
  headers = { 'Content-Type' => 'application/json', 'Content-Length' => body.bytesize.to_s }

  [401, headers, [body]]
end

# TODO: Add custom on_error.
auth_args = {
  secret: OpenSSL::PKey.read(Base64.urlsafe_decode64(ENV['JWT_PUBLIC_KEY'])),
  options: verify_options,
  exclude: %w(/public),
  on_error: on_error
}


Rails.application.config.middleware.use Rack::JWT::Auth, auth_args
