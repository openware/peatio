# encoding: UTF-8
# frozen_string_literal: true

FactoryBot.define do
  factory :wallet do
    trait 'eth_hot' do
      currency_id        'eth'
      name               'Ethereum Hot Wallet'
      address            '249048804499541338815845805798634312140346616732'
      kind               'hot'
      nsig               2
      status             'active'
    end
  end

end