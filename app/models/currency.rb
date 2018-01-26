class Currency < ActiveRecord::Base
  extend Enumerize

  enumerize :type,
            in: %i(fiat coin token),
            predicates: true,
            scope: true

  serialize :options, JSON

  class << self
    delegate :all,
             :all_with_invisible,
             :enumerize,
             :codes,
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
           :quick_withdraw_max,
           :code,
           :as_json,
           :summary,
           to: :'Configs::Currency'

  scope :visible, -> { where(visible: true) }
  scope :invisible, -> { where(visible: false) }

  scope :codes, -> { visible.pluck(:code) }
  scope :coins, -> { where(type: 'coin') }
  scope :coin_codes, -> { coins.pluck(:code) }

end
