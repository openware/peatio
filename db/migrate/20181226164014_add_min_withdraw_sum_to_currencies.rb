class AddMinWithdrawSumToCurrencies < ActiveRecord::Migration
  def change
    change_column :currencies, :withdraw_fee, :decimal, precision: 32, scale: 16, default: 0.0, null: false, after: :deposit_fee
    add_column :currencies, :min_withdraw_amount, :decimal, null: false, default: 0, precision: 32, scale: 16, after: :withdraw_fee
  end
end
