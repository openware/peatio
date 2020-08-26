# encoding: UTF-8
# frozen_string_literal: true

FactoryBot.define do
  factory :withdraw_limit do
    currency_id { 'any' }
    group { 'any' }
    kyc_level { 'any' }
    l24hour { 9999.to_d }
    l1month { 999_999.to_d }
  end
end
