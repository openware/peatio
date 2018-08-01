# encoding: UTF-8
# frozen_string_literal: true

class Currency < ActiveRecord::Base
  serialize :options, JSON

  belongs_to :blockchain, foreign_key: :blockchain_key, primary_key: :key
  # NOTE: type column reserved for STI
  self.inheritance_column = nil

  validates :id, presence: true, uniqueness: true
  validates :type, inclusion: { in: -> (_) { Currency.types.map(&:to_s) } }
  validates :symbol, presence: true, length: { maximum: 1 }
  validates :options, length: { maximum: 1000 }
  validates :quick_withdraw_limit, numericality: { greater_than_or_equal_to: 0 }
  validates :base_factor, numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validates :withdraw_fee, :deposit_fee, numericality: { greater_than_or_equal_to: 0 }
  validate { errors.add(:options, :invalid) unless Hash === options }

  before_validation { self.deposit_fee = 0 unless fiat? }

  after_create { Member.find_each(&:touch_accounts) }
  after_update :disable_markets

  scope :enabled, -> { where(enabled: true) }
  scope :ordered, -> { order(id: :asc) }
  scope :coins,   -> { where(type: :coin) }
  scope :fiats,   -> { where(type: :fiat) }

  class << self
    def codes(options = {})
      pluck(:id).yield_self do |downcase_codes|
        case
          when options.fetch(:bothcase, false)
            downcase_codes + downcase_codes.map(&:upcase)
          when options.fetch(:upcase, false)
            downcase_codes.map(&:upcase)
          else
            downcase_codes
        end
      end
    end

    def coin_codes(options = {})
      coins.codes(options)
    end

    def fiat_codes(options = {})
      fiats.codes(options)
    end

    def types
      %i[fiat coin].freeze
    end
  end

  # Allows to dynamically check value of code:
  #
  #   code.btc? # true if code equals to "btc".
  #   code.xrp? # true if code equals to "xrp".
  #
  def code
    id&.inquiry
  end

  def code=(code)
    self.id = code.to_s.downcase
  end

  types.each { |t| define_method("#{t}?") { type == t.to_s } }

  def as_json(*)
    { code:                     code,
      coin:                     coin?,
      fiat:                     fiat?,
      transaction_url_template: transaction_url_template }
  end

  def summary
    locked  = Account.with_currency(code).sum(:locked)
    balance = Account.with_currency(code).sum(:balance)
    { name:     id.upcase,
      sum:      locked + balance,
      balance:  balance,
      locked:   locked,
      coinable: coin?,
      hot:      coin? ? balance : nil }
  end

  def disable_markets
    unless enabled?
      Market.where('ask_unit = ? OR bid_unit = ?', id, id).update_all(enabled: false)
    end
  end

  class << self
    def nested_attr(*names)
      names.each do |name|
        name_string = name.to_s
        define_method(name)              { options[name_string] }
        define_method(name_string + '?') { options[name_string].present? }
        define_method(name_string + '=') { |value| options[name_string] = value }
        define_method(name_string + '!') { options.fetch!(name_string) }
      end
    end
  end

  nested_attr \
    :erc20_contract_address,
    :supports_cash_addr_format,
    :supports_hd_protocol,
    :allow_multiple_deposit_addresses

  def disabled?
    !enabled
  end

  def transaction_url_template
    blockchain&.explorer_transaction
  end

  def wallet_url_template
    blockchain&.explorer_address
  end

  def blockchain_api
    BlockchainClient[blockchain.key]
  end

  attr_readonly :id,
                :code,
                :type,
                :erc20_contract_address,
                :supports_cash_addr_format,
                :supports_hd_protocol
end

# == Schema Information
# Schema version: 20180708171446
#
# Table name: currencies
#
#  blockchain_key       :string(32)
#  id                   :string(10)       not null, primary key
#  symbol               :string(1)        not null
#  type                 :string(30)       default("coin"), not null
#  deposit_fee          :decimal(32, 16)  default(0.0), not null
#  quick_withdraw_limit :decimal(32, 16)  default(0.0), not null
#  withdraw_fee         :decimal(32, 16)  default(0.0), not null
#  options              :string(1000)     default({}), not null
#  enabled              :boolean          default(TRUE), not null
#  base_factor          :integer          default(1), not null
#  precision            :integer          default(8), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_currencies_on_enabled  (enabled)
#
