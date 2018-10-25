class UpdateAccountIndexes < ActiveRecord::Migration
  def change
    if index_exists?(:accounts, %i[currency_id member_id])
      remove_index :accounts,%i[currency_id member_id]
    end

    unless index_exists?(:accounts, %i[member_id currency_id])
      add_index :accounts, %i[member_id currency_id]
    end

    add_index :accounts, %i[member_id currency_id code], unique: true
  end
end
