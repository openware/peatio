class ReplaceConfirmatioinsCountWithBlockHeader < ActiveRecord::Migration
  def change
    remove_column :deposits,:confirmations
    remove_column :withdraws,:confirmations
    add_column :deposits, :block_number, :integer
    add_column :withdraws, :block_number, :integer
  end
end
