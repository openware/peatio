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

    trait 'eth_warm' do
      currency_id        'eth'
      name               'Ethereum Warm Wallet'
      address            '0x2b9fBC10EbAeEc28a8Fc10069C0BC29E45eBEB9C'
      kind               'warm'
      nsig               2
      status             'active'
    end
  end

end