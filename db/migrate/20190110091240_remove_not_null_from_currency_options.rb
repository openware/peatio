class RemoveNotNullFromCurrencyOptions < ActiveRecord::Migration[5.2]
  def change
    change_column :currencies, :options, :string, limit: 1000, default: '{}', null: true
  end
end
