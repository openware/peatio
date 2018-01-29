class RemoveCurrencyFromAccounts < ActiveRecord::Migration
  def change
    remove_column :accounts, :currency
  end
end