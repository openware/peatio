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

    # TODO: Method should be moved to PlatformEntry.
    # And calculated as balance in assets account.
    def assets_for(currency_id)
      currency_type = Currency.find(currency_id).type.to_sym
      codes = Chart.where(
        currency_type: currency_type,
        type:          :liabilities,
        kind:          :main
      ).map(&:code)
      accounts_ids = Account.where(currency_id: currency_id, code: codes).pluck(:id)
      operations = Operation.where(account_id: accounts_ids)
      operations.sum(:credit) - operations.sum(:debit)
    end

    # TODO: Method should be moved to PlatformEntry.
    # And calculated as balance in locked assets account.
    def locked_assets_for(currency_id)
      currency_type = Currency.find(currency_id).type.to_sym
      codes = Chart.where(
        currency_type: currency_type,
        type:          :liabilities,
        kind:          :locked
      ).map(&:code)
      accounts_ids = Account.where(currency_id: currency_id, code: codes).pluck(:id)
      operations = Operation.where(account_id: accounts_ids)
      operations.sum(:credit) - operations.sum(:debit)
    end
  end
end
