class UpdateAccountIndexes < ActiveRecord::Migration
  def change
    remove_index :accounts,%i[member_id currency_id] if index_exists?(:accounts, %i[member_id currency_id])

    add_index :accounts, %i[member_id currency_id]
    add_index :accounts, %i[member_id currency_id code], unique: true
  end
end
