# encoding: UTF-8
# frozen_string_literal: true


class Wallet < ActiveRecord::Base
  serialize :gateway, JSON

  KIND = %w[hot warm cold deposit].freeze
  CLIENT = %w[bitcoind bitcoincashd litecoind geth dashd rippled bitgo].freeze

  include BelongsToCurrency
  belongs_to :blockchain, foreign_key: :blockchain_key, primary_key: :key

  validates :name, :address, presence: true
  validates :status, inclusion: { in: %w[active disabled] }
  validates :kind, inclusion: { in: KIND }
  validates :nsig, numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validates :max_balance, numericality: { greater_than_or_equal_to: 0}
  # FIXME: add json validation.
  validates :gateway, length: { maximum: 1000 }
  validates :client, inclusion: { in: CLIENT }

  scope :active, -> { where(status: :active) }
  scope :deposit, -> { where(kind: :deposit) }
  scope :withdraw, -> { where.not(kind: :deposit) }

  def wallet_url
    blockchain.explorer_address.gsub('#{address}', address) if blockchain
  end

  class << self
    def gateway_attr(*names)
      names.each do |name|
        name_string = name.to_s
        define_method(name) { gateway[name_string] }
        define_method(name_string + '?') { gateway[name_string].present? }
        define_method(name_string + '=') { |value| gateway[name_string] = value }
        define_method(name_string + '!') { gateway.fetch!(name_string) }
        next unless name == :options
        options_attr.each do |opt_name|
          opt_name_string = opt_name.to_s
          define_method(opt_name) { (gateway[name_string] ||= {})[opt_name_string] }
          define_method(opt_name_string + '?') { (gateway[name_string] ||= {})[opt_name_string].present? }
          define_method(opt_name_string + '=') { |value| (gateway[name_string] ||= {})[opt_name_string] = value }
          define_method(opt_name_string + '!') { (gateway[name_string] ||= {}).fetch!(opt_name_string) }
        end
      end
    end

    def options_attr
      %i[
        uri
        secret
        bitgo_test_net
        bitgo_wallet_id
        bitgo_wallet_address
        bitgo_wallet_passphrase
        bitgo_rest_api_root
        bitgo_rest_api_access_token
      ]
    end
  end

  gateway_attr \
    :client,
    :options

end

# == Schema Information
# Schema version: 20180727054453
#
# Table name: wallets
#
#  id             :integer          not null, primary key
#  blockchain_key :string(32)
#  currency_id    :string(5)
#  name           :string(64)
#  address        :string(255)      not null
#  kind           :string(32)       not null
#  nsig           :integer
#  gateway        :string(1000)     default({}), not null
#  max_balance    :decimal(32, 16)  default(0.0), not null
#  parent         :integer
#  status         :string(32)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
