# encoding: UTF-8
# frozen_string_literal: true

FactoryBot.define do
  factory :order_bid do
    bid { :usd }
    ask { :btc }
    market { Market.find(:btcusd) }
    state { :wait }
    ord_type { 'limit' }
    price { '1'.to_d }
    volume { '1'.to_d }
    origin_volume { volume.to_d }
    locked { price.to_d * volume.to_d }
    origin_locked { locked.to_d }
    member { create(:member) }
  end

  factory :order_ask do
    bid { :usd }
    ask { :btc }
    market { Market.find(:btcusd) }
    state { :wait }
    ord_type { 'limit' }
    price { '1'.to_d }
    volume { '1'.to_d }
    origin_volume { volume.to_d }
    locked { volume.to_d }
    origin_locked { locked.to_d }
    member { create(:member) }
  end

  factory :futures_order_bid do
    base { 'future'}
    bid { :usd }
    ask { :btc }
    market { Market.find(:btcusd1903) }
    state { :wait }
    ord_type { 'limit' }
    price { '1'.to_d }
    volume { '1'.to_d }
    origin_volume { volume.to_d }
    locked { price.to_d * volume.to_d }
    origin_locked { locked.to_d }
    member { create(:member) }
  end

  factory :futures_order_ask do
    base { 'future'}
    bid { :usd }
    ask { :btc }
    market { Market.find(:btcusd1903) }
    state { :wait }
    ord_type { 'limit' }
    price { '1'.to_d }
    volume { '1'.to_d }
    origin_volume { volume.to_d }
    locked { volume.to_d }
    origin_locked { locked.to_d }
    member { create(:member) }
  end  
end
