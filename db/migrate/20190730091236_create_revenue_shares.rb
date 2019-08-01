class CreateRevenueShares < ActiveRecord::Migration[5.2]
  def change
    create_table :revenue_shares do |t|
      t.integer :member_id, null: false, index: true, foreign_key: true
      t.integer :parent_id, null: false, foreign_key: true

      t.integer :pptt, null: false, limit: 2, unsigned: true

      t.integer :state, null: false, index: true, limit: 1, unsigned: true, default: 0
      t.timestamps

    end
    add_index :revenue_shares, %i[member_id state]
  end
end
