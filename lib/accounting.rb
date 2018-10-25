# encoding: UTF-8
# frozen_string_literal: true

module Accounting
  Error = Class.new(StandardError)

  class << self
    def find_or_create_for(member)
      create_member_accounts(member)
      Account.where(member: member)
    end

    private

    def create_member_accounts(member)
      Currency.find_each do |currency|
        Accounting::Chart.codes_for(currency).each do |code|
          Account.find_or_create_by!(
            member:    member,
            currency:  currency,
            code:      code
          )
        end
      end
    end

    def create_platform_accounts(member)
      # TODO:
    end
  end
end
