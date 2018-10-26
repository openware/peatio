# encoding: UTF-8
# frozen_string_literal: true

class Account < ActiveRecord::Base
  AccountError = Class.new(StandardError)

  include BelongsToCurrency
  include BelongsToMember

  ZERO = 0.to_d

  has_many :operations
  has_many :payment_addresses, -> { order(id: :asc) }

  validates :member_id, uniqueness: { scope: %i[currency_id code] }
  # validates :balance, :locked, numericality: { greater_than_or_equal_to: 0.to_d }

  scope :enabled, -> { joins(:currency).merge(Currency.where(enabled: true)) }

  # Returns active deposit address for account or creates new if any exists.
  def payment_address
    return unless currency.coin?
    payment_addresses.last&.enqueue_address_generation || payment_addresses.create!(currency: currency)
  end

  # Attempts to create additional deposit address for account.
  def payment_address!
    return unless currency.coin?
    record = payment_address

    # The address generation process is in progress.
    if record.address.blank?
      record
    else
      # allows user to have multiple addresses.
      payment_addresses.create!(currency: currency)
    end
  end

  def balance
    operations.sum(:credit) - operations.sum(:debit)
  end

  # TODO: Rename this method.
  def locked_account
    return self if code.in?(AccountingService::Chart.locked_codes)
    Account.find_by(
      member_id: member_id,
      currency_id: currency_id,
      code: AccountingService::Chart.locked_codes
    )
  end

  def locked
    # Delegate computation of locked funds to account with locked_code.
    if code.in?(AccountingService::Chart.locked_codes)
      balance
    else
      locked_account.locked
    end
  end

  def lock_operations
    operations.lock
  end

  def with_balance_check!
    transaction do
      yield
      # TODO: Custom Exception message.
      raise AccountError, "Cannot create operation" if balance < 0
    end
  end

  def plus_funds(amount, reference)
    raise AccountError, "Cannot add funds (amount: #{amount})." if amount <= ZERO
    with_balance_check! do
      operations.create!(credit: amount, reference: reference)
    end
    self
  end

  def lock_funds(amount, reference)
    with_balance_check! do
      operations.create!(debit: amount, reference: reference)
      locked_account.plus_funds(amount, reference)
    end
    self
  end

  def unlock_funds(amount, reference)
    with_balance_check! do
      locked_account.sub_funds(amount, reference)
      operations.create!(debit: amount, reference: reference)
    end
    self
  end

  def sub_funds(amount, reference)
    with_balance_check! do
      operations.create!(debit: amount, reference: reference)
    end
    self
  end

  def unlock_and_sub_funds(amount)
    with_balance_check! do
      locked_account.sub_funds(amount, reference)
    end
    self
  end

  def amount
    balance + locked
  end

  def as_json(*)
    super.merge! \
      deposit_address: payment_address&.address,
      currency:        currency_id,
      balance:         balance,
      locked:          locked
  end
end

# == Schema Information
# Schema version: 20181025105206
#
# Table name: accounts
#
#  id          :integer          not null, primary key
#  member_id   :integer          not null
#  currency_id :string(10)       not null
#  code        :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_accounts_on_member_id                           (member_id)
#  index_accounts_on_member_id_and_currency_id           (member_id,currency_id)
#  index_accounts_on_member_id_and_currency_id_and_code  (member_id,currency_id,code) UNIQUE
#
