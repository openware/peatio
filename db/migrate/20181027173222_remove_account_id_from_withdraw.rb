class RemoveAccountIdFromWithdraw < ActiveRecord::Migration
  def change
    remove_column :withdraws, :account_id
  end
end
