class CurrencyRefactorAccounts < ActiveRecord::Migration
  def change
    remove_column :accounts, :currency, :integer
    add_column :accounts, :currency_id, :integer, unsigned: true
  end
end
