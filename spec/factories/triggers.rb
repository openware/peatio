# encoding: UTF-8
# frozen_string_literal: true

FactoryBot.define do
  factory :trigger do
    order     { create(:order_ask, :with_deposit_liability, :btcusd)}
    value     { 1.1.to_d }
    ord_type  { Trigger::TYPES.keys.sample }
  end
end
