FactoryBot.define do
  factory :fund_source do
    extra 'bitcoin'
    uid { Faker::Bitcoin.address }
    is_locked false
    currency 'btc'

    member { create(:member) }

    trait Peatio.base_fiat_ccy_sym.downcase do
      extra 'bc'
      uid '123412341234'
      currency Peatio.base_fiat_ccy.downcase
    end

    factory :base_fiat_ccy_fund_source, traits: [Peatio.base_fiat_ccy_sym.downcase]
    factory :btc_fund_source
  end
end
