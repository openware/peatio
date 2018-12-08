class AddBaseAndExpiredAtToMarkets < ActiveRecord::Migration
  def change
    add_column :markets, :base, :string, default: 'spot'
    add_column :markets, :expired_at, :datetime
    add_column :markets,
      :margin_rate,
      :decimal,
      precision: 32,
      scale: 16,
      default: 0.1,
      null: false
    add_column :markets,
      :maintenance_rate,
      :decimal,
      default: 0.75,
      precision: 2,
      scale: 2,
      null: false

    remove_index :markets, column: %i[ask_unit bid_unit]
    add_index :markets, %i[base ask_unit bid_unit], unique: true
  end
end
