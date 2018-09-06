# encoding: UTF-8
# frozen_string_literal: true

FactoryBot.define do
  factory :upstream do
    trait :binance do
      provider    { 'binance' }
      api_key     { Faker::Lorem.characters(24) }
      api_secret  { Faker::Lorem.characters(24) }
      timeout     { 0 }
      enabled     { true }
    end
  end
end
