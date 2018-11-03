# encoding: UTF-8
# frozen_string_literal: true

module AccountingService
  class PlatformEntry < MemberEntry

    def plus_revenue(amount, reference, currency = nil)
      validate_amount!(amount)

      with_balance_check! do
        main_revenue_account(currency || reference.currency).operations.create!(credit: amount, reference: reference)
      end
      self
    end

    def plus_expense(amount, reference, currency = nil)
      validate_amount!(amount)

      with_balance_check! do
        main_expense_account(currency || reference.currency).operations.create!(credit: amount, reference: reference)
      end
      self
    end

    private

    def main_revenue_account(currency)
      account(kind: :main, currency_type: (currency.fiat? ? :fiat : :coin), type: :revenue)
    end

    def main_expense_account(currency)
      account(kind: :main, currency_type: (currency.fiat? ? :fiat : :coin), type: :expense)
    end
  end
end
