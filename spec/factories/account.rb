# encoding: UTF-8
# frozen_string_literal: true

module AccountFactory
  def create_account(*arguments)
    currency   = Symbol === arguments.first ? arguments.first : :usd
    attributes = arguments.extract_options!
    member     = attributes.delete(:member) { create(:member) }
    if attributes.key?(:balance) || attributes.key?(:locked)
      create(
        "deposit_#{currency}",
        member: member,
        amount: attributes.fetch(:balance) + attributes.fetch(:locked)
      ).accept!
    end
    if attributes.key?(:locked)
      create(
        "#{currency}_withdraw",
        member: member,
        sum: attributes.fetch(:locked)
      ).submit!
    end
    member.ac(currency)
  end
end

RSpec.configure { |config| config.include AccountFactory }
