# encoding: UTF-8
# frozen_string_literal: true

module AccountingService
  Error = Class.new(StandardError)

  ZERO = 0.to_d
  class << self
    def find_or_create_for(owner, currency_id)
      "AccountingService::#{owner.type.capitalize}Entry"
        .constantize
        .new(owner: owner, currency_id: currency_id)
        .tap(&:initialize_accounts!)
    end
  end
end
