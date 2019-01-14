class RemoveNotNullFromCurrencyOptions < ActiveRecord::Migration[5.2]
  def change
    change_column :currencies, :options, :string, null: true
  end
end
