FactoryBot.define do
  factory :payment_address do
    address 'MyString'
    account { create(:member).get_account(:usd) }

    trait :btc_address do
      currency { Currency.btc }
      address { Faker::Bitcoin.address }
      account { create(:member).get_account(:btc) }
    end

    factory :btc_payment_address, traits: [:btc_address]
  end
end
