# encoding: UTF-8
# frozen_string_literal: true

module AccountingService
  class MemberEntry
    include ActiveModel::Model
    extend Memoist
    attr_accessor :owner, :currency_id

    def accounts
      @accounts ||= initialize_accounts!
    end

    def chart
      @chart ||=
        AccountingService::Chart.new(owner: owner, currency_id: currency_id)
    end

    # @deprecated This method added for compatibility with Account.
    def currency
      Currency.find_by_id(currency_id)
    end

    # @deprecated This method added for compatibility with Account.
    def member
      owner
    end

    memoize :currency, :member

    # @deprecated This method added for compatibility with Account.
    def as_json(*)
      # super.merge! \
      # deposit_address: payment_address&.address,
      # currency:        currency_id,
      # balance:         balance,
      # locked:          locked
      {
        currency:        currency_id,
        balance:         balance,
        locked:          locked
      }
    end

    def operations
      Operation.where(account_id: accounts.ids)
    end

    def initialize_accounts!
      chart.codes.map do |code|
        Account.find_or_create_by!(
          member:       owner,
          currency_id:  currency_id,
          code:         code
        )
      end
      Account.where(currency_id: currency_id, member: owner)
    end

    def balance
      operations = account(kind: :main, type: :liabilities).operations
      operations.sum(:credit) - operations.sum(:debit)
    end

    def locked
      operations = account(kind: :locked, type: :liabilities).operations
      operations.sum(:credit) - operations.sum(:debit)
    end

    def amount; balance + locked; end

    def plus_funds(amount, reference, currency = nil)
      validate_amount!(amount)

      with_balance_check! do
        main_asset_account(currency || reference.currency).operations.create!(credit: amount, reference: reference)
        main_liability_account(currency || reference.currency).operations.create!(credit: amount, reference: reference)
      end
      self
    end

    def lock_funds(amount, reference, currency = nil)
      validate_amount!(amount)

      with_balance_check! do
        raise AccountingService::Error, "Cannot lock funds (amount: #{amount})." if amount <= 0 || amount > balance
        main_asset_account(currency || reference.currency).operations.create!(debit: amount, reference: reference)
        main_liability_account(currency || reference.currency).operations.create!(debit: amount, reference: reference)
        locked_liability_account(currency || reference.currency).operations.create!(credit: amount, reference: reference)
      end
      self
    end

    def unlock_funds(amount, reference, currency = nil)
      validate_amount!(amount)

      with_balance_check! do
        raise AccountingService::Error, "Cannot unlock funds (amount: #{amount})." if amount <= 0 || amount > locked
        locked_liability_account(currency || reference.currency).operations.create!(debit: amount, reference: reference)
        main_liability_account(currency || reference.currency).operations.create!(credit: amount, reference: reference)
        main_asset_account(currency || reference.currency).operations.create!(credit: amount, reference: reference)
      end
      self
    end

    def unlock_and_sub_funds(amount, reference, currency = nil)
      validate_amount!(amount)

      with_balance_check! do
        raise AccountingService::Error, "Cannot unlock funds (amount: #{amount})." if amount <= 0 || amount > locked
        locked_liability_account(currency || reference.currency).operations.create!(debit: amount, reference: reference)
      end
      self
    end

  private
    def account(options={})
      codes = chart.codes(options)
      accounts.find_by(code: codes)
    end

    def main_liability_account(currency)
      account(kind: :main, currency_type: (currency.fiat? ? :fiat : :coin), type: :liabilities)
    end

    def locked_liability_account(currency)
      account(kind: :locked, currency_type: (currency.fiat? ? :fiat : :coin), type: :liabilities)
    end

    def main_asset_account(currency)
      account(kind: :main, currency_type: (currency.fiat? ? :fiat : :coin), type: :assets)
    end

    def with_balance_check!
      ActiveRecord::Base.transaction do
        yield
        # TODO: Custom Exception message.
        # TODO: AccountingService::Error.
        raise AccountingService::Error, "Cannot create operation" if balance < 0
      end
    end

    protected

    def validate_amount!(amount)
      raise AccountingService::Error, "Amount can't be negative (amount: #{amount})." if amount < 0
    end
  end
end
