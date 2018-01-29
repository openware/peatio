class AddCurrencyIdToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :currency_id, :integer, unsigned: true
  end
end