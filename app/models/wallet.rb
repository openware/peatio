# encoding: UTF-8
# frozen_string_literal: true


class Wallet < ActiveRecord::Base
  extend Enumerize

  # We use this attribute values rules for wallet kinds:
  # 1** - for deposit wallets
  # 2** - for withdraw wallets
  ENUMERIZED_KINDS = { deposit: 100, hot: 210, warm: 220, cold: 230 }.freeze
  enumerize :kind, in: ENUMERIZED_KINDS, scope: true

  DEPOSIT_KINDS  = ENUMERIZED_KINDS.select { |_k, v| v / 100 == 1 }.keys.freeze
  WITHDRAW_KINDS = ENUMERIZED_KINDS.select { |_k, v| v / 100 == 2 }.keys.freeze
  KINDS          = (DEPOSIT_KINDS + WITHDRAW_KINDS).freeze

  GATEWAYS = %w[bitcoind bitcoincashd litecoind geth dashd rippled bitgo].freeze
  SETTING_ATTRIBUTES = %i[ uri
                           secret
                           bitgo_test_net
                           bitgo_wallet_id
                           bitgo_wallet_passphrase
                           bitgo_rest_api_root
                           bitgo_rest_api_access_token ].freeze

  include BelongsToCurrency

  store :settings, accessors: SETTING_ATTRIBUTES, coder: JSON

  belongs_to :blockchain, foreign_key: :blockchain_key, primary_key: :key

  validates :name,    presence: true, uniqueness: true
  validates :address, presence: true

  validates :status,  inclusion: { in: %w[active disabled] }
  validates :gateway, inclusion: { in: GATEWAYS }

  validates :nsig,        numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validates :max_balance, numericality: { greater_than_or_equal_to: 0 }
  validates :uri, url: { allow_blank: true }

  scope :active,   -> { where(status: :active) }
  scope :deposit,  -> { with_kind(DEPOSIT_KINDS) }
  scope :withdraw, -> { with_kind(WITHDRAW_KINDS) }
  scope :ordered,  -> { order(kind: :asc) }

  before_validation do
    next unless blockchain_api&.supports_cash_addr_format? && address?
    self.address = CashAddr::Converter.to_cash_address(address)
  end

  def wallet_url
    blockchain.explorer_address.gsub('#{address}', address) if blockchain
  end
end

# == Schema Information
# Schema version: 20181017114624
#
# Table name: wallets
#
#  id             :integer          not null, primary key
#  blockchain_key :string(32)
#  currency_id    :string(10)
#  name           :string(64)
#  address        :string(255)      not null
#  kind           :integer          not null
#  nsig           :integer
#  gateway        :string(20)       default(""), not null
#  settings       :string(1000)     default({}), not null
#  max_balance    :decimal(32, 16)  default(0.0), not null
#  parent         :integer
#  status         :string(32)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_wallets_on_currency_id                      (currency_id)
#  index_wallets_on_kind                             (kind)
#  index_wallets_on_kind_and_currency_id_and_status  (kind,currency_id,status)
#  index_wallets_on_status                           (status)
#
