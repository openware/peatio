# encoding: UTF-8
# frozen_string_literal: true

FactoryBot.define do
  sequence :percent do
    Kernel.rand(1..10000).to_d / 100
  end

  factory :revenue_share do
    member  { create(:member) }
    parent  { create(:member) }
    percent { generate(:percent) }
    state   { :active }
  end
end
