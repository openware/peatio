class AddDepositFeeToCurrencies < ActiveRecord::Migration
  def change
    add_column :currencies, :deposit_fee, :decimal, after: :withdraw_fee, null: false, default: 0, precision: 32, scale: 16
  end
end
