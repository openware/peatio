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

  validates :key,
            :code,
            :name,
            length: { maximum: 30 },
            presence: true

  validates :code,
            uniqueness: true,
            presence: true

  validates :symbol, length: { maximum: 1 }
  validates :type,
            length: { maximum: 30 }
  validates :json_rpc_endpoint,
            :rest_api_endpoint,
            length: { maximum: 200 },
            url: { allow_blank: true }
  validates :hot_wallet_address,
            length: { maximum: 200 },
            presence: true
  validates :options,
            length: { maximum: 1000 }
  validates :wallet_url_template,
            :transaction_url_template,
            length: { maximum: 200 },
            url: { allow_nil: true, allow_blank: false }
  validates :quick_withdraw_limit,
            numericality: { greater_than_or_equal_to: 0 },
            presence: true
  validates :visible,
            presence: true
  validates :base_factor,
            numericality: { greater_than_or_equal_to: 0 }

  class << self
    delegate :assets,
             # :enumerize,
             # :all,
             # :all_with_invisible,
             # :codes,
             # :ids,
             to: :'Configs::Currency'
  end

  delegate :precision,
           :api,
           # :fiat?,
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
    return {} unless ActiveRecord::Base.connection.table_exists?('currencies')
    all.inject({}) {|memo, i| memo[i.code.to_sym] = i.id; memo}
  end

  def self.ids
    visible.ids
  end

  codes.each do |code|
    define_singleton_method code.downcase do
      find_by!(code: code)
    end
  end

  def currency_value
    code
  end

  def code=(code)
    write_attribute(:code, code.to_s.upcase)
  end

end
