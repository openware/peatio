class DropAccountBalanceAndLocked < ActiveRecord::Migration
  def change
    remove_columns :accounts, :balance, :locked
  end
end
