# encoding: UTF-8
# frozen_string_literal: true

FactoryBot.define do
  factory :trigger do
    order { create(:order_ask, :with_deposit_liability, :btcusd)}
    price { 1.1.to_d }
    type  { Trigger::TYPES.sample }
  end
end
