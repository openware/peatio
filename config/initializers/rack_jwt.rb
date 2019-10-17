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

auth_args = {
  secret: OpenSSL::PKey.read(Base64.urlsafe_decode64(ENV['JWT_PUBLIC_KEY'])),
  options: verify_options,
  exclude: %w(/public),
  on_error: 1
}


Rails.application.config.middleware.use Rack::JWT::Auth, auth_args
