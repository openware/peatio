# encoding: UTF-8
# frozen_string_literal: true

# TODO: Add specs.
class Wallet < ActiveRecord::Base
  include BelongsToCurrency

  validates :name, :address, presence: true
  validates :status, inclusion: { in: %w[active disabled] }
  validates :kind, inclusion: { in: %w[hot warm cold deposit] }
  validates :nsig, numericality: { greater_than_or_equal_to: 1, only_integer: true }

  before_validation do
    self.address = address.try(:downcase)
  end

  scope :active, -> { where(status: 'active') }

  def wallet_url
    if currency.wallet_url_template?
      currency.wallet_url_template.gsub('#{address}', address)
    end
  end
end

# == Schema Information
# Schema version: 20180708171446
#
# Table name: wallets
#
#  id          :integer          not null, primary key
#  currency_id :string(5)
#  name        :string(64)
#  address     :string(255)      not null
#  kind        :string(32)       not null
#  nsig        :integer
#  parent      :integer
#  status      :string(32)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
