class MigrateMarkets < ActiveRecord::Migration

  # Migrate markets.yml to database 'markets' table
  #
  # - remove code from all markets
  # - rename base_unit to ask_unit
  # - rename quote_unit to bid_unit
  # - rename sort_order to position
  # - move ask.fee to ask_fee.
  # - move bid.fee to bid_fee
  # - remove ask.currency
  # - remove bid.currency
  # - move ask.fixed to ask_precision
  # - move bid.fixed to bid_precision
  #
  # eg, from markets.yml with ..
  #
  # - id: btcusd
  #   code: 101
  #   base_unit: btc
  #   quote_unit: usd
  #   sort_order: 1
  #   bid: { fee: 0.0015, currency: usd, fixed: 2 }
  #   ask: { fee: 0.0015, currency: btc, fixed: 4 }
  #
  # .. to 'markets' table record with ..
  #
  #   id: btcusd
  #   ask_unit: btc
  #   bid_unit: usd
  #   position: 1
  #   bid_fee: 0.0015
  #   bid_precision: 2
  #   ask_fee: 0.0015
  #   ask_precision: 4

  class Market20180325001829 < ActiveRecord::Base
    self.table_name = 'markets'
  end

  def up
    yml_file_location = Rails.root.join('config/markets.yml')
    if File.file?(yml_file_location)
      YAML.load_file(yml_file_location).each do |yml_market|
        next if Market20180325001829.exists?(id: yml_market.fetch('id'))
        attrs = {
          id:             yml_market['id'],
          ask_unit:       yml_market['base_unit'],
          bid_unit:       yml_market['quote_unit'],
          position:       yml_market['sort_order'],
          ask_fee:        yml_market['ask']['fee'],
          ask_precision:  yml_market['ask']['fixed'],
          bid_fee:        yml_market['bid']['fee'],
          bid_precision:  yml_market['bid']['fixed']
        }
        Market20180325001829.create!(attrs)
      end
    end
  end

  def down
    # do nothing
  end

end
