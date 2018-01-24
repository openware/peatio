class AddVisibleToCurrencies < ActiveRecord::Migration
  def change
    add_column :currencies, :visible, :boolean, default: true
  end
end