# encoding: UTF-8
# frozen_string_literal: true

class AccountingEquationValidator < ActiveModel::Validator
  # For validating Accounting Equation we use next formula:
  # Assets - Liabilities = Revenues - Expenses
  # Which is equal to:
  # Assets + Expenses - Liabilities - Revenues = 0
  def validate(record)
    balance_sheet = Hash.new(0)
    if record.is_a?(Transfer)
      (record.assets + record.expenses).each do |op|
        balance_sheet[op.currency_id] += op.amount
      end
      (record.liabilities + record.revenues).each do |op|
        balance_sheet[op.currency_id] -= op.amount
      end
    elsif record.is_a?(Adjustment)
      [record.asset, record.expense].compact.each do |op|
        balance_sheet[op.currency_id] += op.amount
      end
      [record.liability, record.revenue].compact.each do |op|
        balance_sheet[op.currency_id] -= op.amount
      end
    end

    balance_sheet.delete_if { |_k, v| v.zero? }

    unless balance_sheet.empty?
      record.errors.add(:base, "invalidates accounting equation for #{balance_sheet.keys.join(', ')}")
    end
  end
end
