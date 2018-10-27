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
      operations = account(kind: :main).operations
      operations.sum(:credit) - operations.sum(:debit)
    end

    def locked
      operations = account(kind: :locked).operations
      operations.sum(:credit) - operations.sum(:debit)
    end

    def amount; balance + locked; end

    def plus_funds(amount, reference)
      if amount <= AccountingService::ZERO
        raise Account::AccountError, "Cannot add funds (amount: #{amount})."
      end

      with_balance_check! do
        main_account.operations.create!(credit: amount, reference: reference)
      end
      self
    end

    def lock_funds(amount, reference)
      with_balance_check! do
        main_account.operations.create!(debit: amount, reference: reference)
        locked_account.operations.create!(credit: amount, reference: reference)
      end
      self
    end

    def unlock_funds(amount, reference)
      with_balance_check! do
        locked_account.operations.create!(debit: amount, reference: reference)
        main_account.operations.create!(debit: amount, reference: reference)
      end
      self
    end

    def unlock_and_sub_funds(amount, reference)
      with_balance_check! do
        locked_account.operations.create!(debit: amount, reference: reference)
      end
      self
    end

  private
    def account(options={})
      codes = chart.codes(options)
      accounts.find_by(code: codes)
    end

    def main_account; account(kind: :main); end
    def locked_account; account(kind: :locked); end
    memoize :main_account, :locked_account

    def with_balance_check!
      ActiveRecord::Base.transaction do
        yield
        # TODO: Custom Exception message.
        # TODO: AccountingService::Error.
        raise Account::AccountError, "Cannot create operation" if balance < 0
      end
    end
  end
end
