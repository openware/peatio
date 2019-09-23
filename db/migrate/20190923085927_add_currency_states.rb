class AddCurrencyStates < ActiveRecord::Migration[5.2]
  def change
    add_column :currencies, :deposit_enabled, :boolean, default: true, null: false, after: :enabled
    add_column :currencies, :withdrawal_enabled, :boolean, default: true, null: false, after: :deposit_enabled
    rename_column :currencies, :enabled, :visible
  end
end
