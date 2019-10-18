# encoding: UTF-8
# frozen_string_literal: true

require_relative 'jwt'
require 'rack/jwt'

on_error = lambda do |_error|
  message = 'jwt.decode_and_verify'
  body    = { errors: [message] }.to_json
  headers = { 'Content-Type' => 'application/json', 'Content-Length' => body.bytesize.to_s }

  [401, headers, [body]]
end

auth_args = {
  secret:   Rails.configuration.x.jwt_public_key,
  options:  Rails.configuration.x.jwt_options,
  verify:   Rails.configuration.x.jwt_public_key.present?,
  exclude:  %w(/api/v2/public /api/v2/management),
  on_error: on_error
}

Rails.application.config.middleware.use Rack::JWT::Auth, auth_args
