class ExtendFees < ActiveRecord::Migration
  def change
    add_column :fees, :account_id, :integer, limit: 4
    add_column :fees, :amount,  :decimal, precision: 32, scale: 16
  end
end
