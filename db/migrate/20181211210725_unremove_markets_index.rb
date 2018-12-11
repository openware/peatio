class UnremoveMarketsIndex < ActiveRecord::Migration
  def change
    add_index :markets, %i[ask_unit bid_unit]
  end
end
