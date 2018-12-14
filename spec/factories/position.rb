# encoding: UTF-8
# frozen_string_literal: true

FactoryBot.define do
  factory :position do
    market { Market.find(:btcusd1903) }
    member { create(:member) }
    volume { '1'.to_d }
    margin { '380'.to_d }
    credit { '3991'.to_d }    
  end
end
