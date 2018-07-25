class ReplaceConfirmatioinsCountWithBlockHeader < ActiveRecord::Migration
  def change
    remove_column :deposits,:confirmations, :string, limit: 255, after: :rid
    remove_column :withdraws, :confirmations, :integer, limit: 4, default: 0, null: false, after: :rid
    add_column :deposits, :block_number, :integer, after: :aasm_state
    add_column :withdraws, :block_number, :integer, after: :aasm_state
  end
end
