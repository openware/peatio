class Currency < ActiveRecord::Base
  extend Enumerize
  
  # NOTE: alias attributes during refactoring
  alias_attribute :quick_withdraw_max,
                  :quick_withdraw_limit

  alias_attribute :rpc,
                  :json_rpc_endpoint

  enumerize :type,
            in: %i(fiat coin token),
            predicates: true,
            scope: true

  serialize :options, JSON

  class << self
    delegate :enumerize,
             # :all,
             # :all_with_invisible,
             # :codes,
             :ids,
             :assets,
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
  default_scope { visible }
  scope :invisible, -> { where(visible: false) }
  scope :all_with_invisible, -> { 'visible is true or visible is false' }

  scope :codes, -> { visible.pluck(:code) }
  scope :coins, -> { where(type: 'coin') }
  scope :coin_codes, -> { coins.pluck(:code) }

end
