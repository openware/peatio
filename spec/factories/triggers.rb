# encoding: UTF-8
# frozen_string_literal: true

FactoryBot.define do
  factory :trigger do
    trigger_price { 0.11.to_d }
    side { %i(buy sels).sample }
    amount { 1.1.to_d }
    price { 0.1.to_d }
    order { create(:order_ask, :with_deposit_liability, :btcusd) }
    status { Trigger::STATES.values.sample }
  end
end
