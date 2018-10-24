# encoding: UTF-8
# frozen_string_literal: true

FactoryBot.define do
  factory :payment_address do
    address { Faker::Bitcoin.address }
    currency { Currency.find(:usd) }
    account { create(:member, :level_3).get_account(:usd) }

    trait :btc_address do
      currency { Currency.find(:btc) }
      account { create(:member, :level_3).get_account(:btc) }
    end

    trait :eth_address do
      currency { Currency.find(:eth) }
      account { create(:member, :level_3).get_account(:eth) }
    end

    trait :trst_address do
      currency { Currency.find(:trst) }
      account { create(:member, :level_3).get_account(:trst) }
    end

    trait :ltc_address do
      currency { Currency.find(:ltc) }
      account { create(:member, :level_3).get_account(:ltc) }
    end

    trait :dash_address do
      currency { Currency.find(:dash) }
      account { create(:member, :level_3).get_account(:dash) }
    end

    trait :bch_address do
      currency { Currency.find(:bch) }
      account { create(:member, :level_3).get_account(:bch) }
    end

    trait :xrp_address do
      currency { Currency.find(:xrp) }
      account { create(:member, :level_3).get_account(:xrp) }
    end

    trait :nxt_address do
      currency { Currency.find(:nxt) }
      account { create(:member, :level_3).get_account(:nxt) }
    end

    trait :testp_address do
      currency { Currency.find(:testp) }
      account { create(:member, :level_3).get_account(:testp) }
    end

    trait :testa_address do
      currency { Currency.find(:testa) }
      account { create(:member, :level_3).get_account(:testa) }
    end

    trait :wcg_address do
      currency { Currency.find(:wcg) }
      account { create(:member, :level_3).get_account(:wcg) }
    end

    trait :drt_address do
      currency { Currency.find(:drt) }
      account { create(:member, :level_3).get_account(:drt) }
    end

    factory :btc_payment_address, traits: [:btc_address]
    factory :eth_payment_address, traits: [:eth_address]
    factory :trst_payment_address, traits: [:trst_address]
    factory :dash_payment_address, traits: [:dash_address]
    factory :ltc_payment_address, traits: [:ltc_address]
    factory :bch_payment_address, traits: [:bch_address]
    factory :xrp_payment_address, traits: [:xrp_address]
    factory :nxt_payment_address, traits: [:nxt_address]
    factory :testp_payment_address, traits: [:testp_address]
    factory :testa_payment_address, traits: [:testa_address]
    factory :wcg_payment_address, traits: [:wcg_address]
    factory :drt_payment_address, traits: [:drt_address]
  end
end
