# encoding: UTF-8
# frozen_string_literal: true

FactoryBot.define do
  factory :liability_history do
    member_id { create(:member, :level_3).id }
    liability_id { rand(1...100) }
    operation_type { ['Trade', 'Deposit', 'Withdraw'].sample }
    operation_id { rand(1...100) }
    currency_id { 'eth' }
    debit { 0.12 }
    credit { 0.0 }
    fee { 0.001 }
    fee_currency_id { 'usd' }
    txid { 'test' }
    operation_date { DateTime.now }
    market_id { 'ethusd' }
    price { 0.12 }
    side { 'ask' }
  end
end
