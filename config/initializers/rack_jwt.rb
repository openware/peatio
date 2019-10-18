# encoding: UTF-8
# frozen_string_literal: true

require 'rack/jwt'

Rails.configuration.x.jwt_public_key =
  if ENV['JWT_PUBLIC_KEY'].present?
    key = OpenSSL::PKey.read(Base64.urlsafe_decode64(ENV['JWT_PUBLIC_KEY']))
    raise ArgumentError, 'JWT_PUBLIC_KEY was set to private key, however it should be public.' if key.private?
    key
  end

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
  algorithm: ENV.fetch("JWT_ALGORITHM", "RS256"),
  leeway: ENV["JWT_DEFAULT_LEEWAY"].yield_self { |n| n.to_i unless n.nil? },
  iat_leeway: ENV["JWT_ISSUED_AT_LEEWAY"].yield_self { |n| n.to_i unless n.nil? },
  exp_leeway: ENV["JWT_EXPIRATION_LEEWAY"].yield_self { |n| n.to_i unless n.nil? },
  nbf_leeway: ENV["JWT_NOT_BEFORE_LEEWAY"].yield_self { |n| n.to_i unless n.nil? },
}.compact

verify_options[:algorithm] = 'none' if Rails.configuration.x.jwt_public_key.blank?

on_error = lambda do |_error|
  message = 'jwt.decode_and_verify'
  body    = { errors: [message] }.to_json
  headers = { 'Content-Type' => 'application/json', 'Content-Length' => body.bytesize.to_s }

  [401, headers, [body]]
end

auth_args = {
  secret:   Rails.configuration.x.jwt_public_key,
  options:  verify_options,
  verify:   Rails.configuration.x.jwt_public_key.present?,
  exclude:  %w(/api/v2/public /api/v2/management),
  on_error: on_error
}

Rails.application.config.middleware.use Rack::JWT::Auth, auth_args
