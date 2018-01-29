class Currency < ActiveRecord::Base
  extend Enumerize

  # NOTE: alias attributes during refactoring
  alias_attribute :quick_withdraw_max,
                  :quick_withdraw_limit

  alias_attribute :rpc,
                  :json_rpc_endpoint

  # NOTE: type column reserved for STI
  self.inheritance_column = nil
  enumerize :type,
            in: %i(fiat coin token),
            predicates: true,
            scope: true

  serialize :options, JSON

  class << self
    delegate :assets,
             :enumerize,
             # :all,
             # :all_with_invisible,
             # :codes,
             # :ids,
             to: :'Configs::Currency'
  end

  delegate :precision,
           :api,
           :fiat?,
           :balance_cache_key,
           :balance,
           :decimal_digit,
           :refresh_balance,
           :blockchain_url,
           :address_url,
           # :quick_withdraw_max,
           # :code,
           :as_json,
           :summary,
           to: :'Configs::Currency'

  scope :visible, -> { where(visible: true) }
  scope :invisible, -> { where(visible: false) }
  scope :all_with_invisible, -> { all }

  scope :codes, -> { visible.pluck(:code) }
  scope :coins, -> { where(type: 'coin') }
  scope :coin_codes, -> { coins.pluck(:code) }

  def self.enumerize
    all.inject({}) {|memo, i| memo[i.code.to_sym] = i.id; memo}
  end

  def code
    read_attribute(:code).to_sym
  end

  def currency_value
    code
  end

end
