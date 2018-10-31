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

  def plus_funds(amount, reference)
    accounting_service.plus_funds(amount, reference)
  end

  def lock_funds(amount, reference)
    accounting_service.lock_funds(amount, reference)
  end

  def unlock_funds(amount, reference)
    accounting_service.unlock_funds(amount, reference)
  end

  def unlock_and_sub_funds(amount, reference)
    accounting_service.unlock_and_sub_funds(amount, reference)
  end

  def accounting_service
    AccountingService.find_or_create_for(member, currency_id)
  end

  # @deprecated
  def balance
    accounting_service.balance
  end

  # @deprecated
  def locked
    accounting_service.locked
  end

  # @deprecated
  def amount
    accounting_service.amount
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
