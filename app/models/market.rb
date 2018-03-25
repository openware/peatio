# People exchange commodities in markets. Each market focuses on certain
# commodity pair `{A, B}`. By convention, we call people exchange A for B
# *sellers* who submit *ask* orders, and people exchange B for A *buyers*
# who submit *bid* orders.
#
# ID of market is always in the form "#{B}#{A}". For example, in 'btcusd'
# market, the commodity pair is `{btc, usd}`. Sellers sell out _btc_ for
# _usd_, buyers buy in _btc_ with _usd_. _btc_ is the `base_unit`, while
# _usd_ is the `quote_unit`.
#
# Given market BTCUSD.
# Ask unit = USD.
# Bid unit = BTC.
#

class Market < ActiveRecord::Base

  class << self
    extend Memoist

    def ask_units
      order(id: :asc).pluck(:ask_unit)
    end

    def bid_units
      order(id: :asc).pluck(:bid_unit)
    end

    # TODO: Rename to find_by_commodity_pair.
    def by_name(name)
      where('CONCAT(ask_unit, bid_unit) = ?', name)
    end

    def to_hash
      all.each_with_object({}) do |market, memo|
        memo[market.commodity_pair] = { name: market.name, bid_unit: market.bid_unit, ask_unit: market.ask_unit }
      end
    end
    memoize :to_hash
  end

  def self.enumerize
    all.inject({}) {|hash, i| hash[i.name.to_sym] = i.id; hash }
  end

  def commodity_pair
    (ask_unit + bid_unit).to_sym
  end

  # @deprecated
  def base_unit
    ask_unit
  end

  # @deprecated
  def quote_unit
    bid_unit
  end

  # @deprecated
  def bid
    { fee: bid_fee, currency: bid_unit, fixed: bid_precision }
  end

  # @deprecated
  def ask
    { fee: ask_fee, currency: ask_unit, fixed: ask_precision }
  end

  def name
    "#{ask_unit}/#{bid_unit}"
  end

  alias to_s name

  def latest_price
    Trade.latest_price(id.to_sym)
  end

  # type is :ask or :bid
  def fix_number_precision(type, d)
    digits = send(type)['fixed']
    d.round digits, BigDecimal::ROUND_DOWN
  end

  # shortcut of global access
  def bids;   global.bids   end
  def asks;   global.asks   end
  def trades; global.trades end
  def ticker; global.ticker end

  def ask_currency
    Currency.find_by!(code: ask_unit)
  end

  def bid_currency
    Currency.find_by!(code: bid_unit)
  end

  def scope?(account_or_currency)
    code = if account_or_currency.is_a? Account
             account_or_currency.currency
           elsif account_or_currency.is_a? Currency
             account_or_currency.code
           else
             account_or_currency
           end

    ask_unit == code || bid_unit == code
  end

  def unit_info
    {name: name, base_unit: ask_unit, quote_unit: bid_unit}
  end

  def global
    Global[commodity_pair]
  end
end

# == Schema Information
# Schema version: 20180303121013
#
# Table name: markets
#
#  id            :string(10)       not null, primary key
#  ask_unit      :string(5)        not null
#  bid_unit      :string(5)        not null
#  ask_fee       :decimal(7, 6)    default(0.0), not null
#  bid_fee       :decimal(7, 6)    default(0.0), not null
#  ask_precision :integer          default(4), not null
#  bid_precision :integer          default(4), not null
#  position      :integer          default(0), not null
#  visible       :integer          default(1), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_markets_on_ask_unit               (ask_unit)
#  index_markets_on_ask_unit_and_bid_unit  (ask_unit,bid_unit) UNIQUE
#  index_markets_on_bid_unit               (bid_unit)
#  index_markets_on_position               (position)
#  index_markets_on_visible                (visible)
#
