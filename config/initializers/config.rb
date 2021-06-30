# frozen_string_literal: true

require 'peatio/app'

Peatio::App.define do |config|
  config.set(:deposit_funds_locked, 'false', type: :bool)
  config.set(:default_account_type, 'spot')
  config.set(:account_types, '')
end
