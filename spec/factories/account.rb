# encoding: UTF-8
# frozen_string_literal: true

module AccountFactory
  def create_account(*arguments)
    currency   = Symbol === arguments.first ? arguments.first : :usd
    attributes = arguments.extract_options!
    member     = attributes.delete(:member) { create(:member) }
    if attributes.key?(:balance)
      locked = attributes.key?(:locked) ? attributes.fetch(:locked) : 0
      create(
        "deposit_#{currency}",
        member: member,
        amount: attributes.fetch(:balance) + locked
      ).accept!
    end
    if attributes.key?(:locked)
      rid = if attributes.key?(:rid)
              attributes.fetch(:rid)
            elsif currency == :usd
              Faker::Bank.iban
            else
              Faker::Bitcoin.address
            end
      create(
        "#{currency}_withdraw",
        member: member,
        sum: attributes.fetch(:locked),
        rid: rid
      ).submit!
    end
    member.ac(currency)
  end
end

RSpec.configure { |config| config.include AccountFactory }
