class CreatePositions < ActiveRecord::Migration
  def change
    create_table :positions do |t|
      t.belongs_to :member, null: false
      t.string :market_id, limit: 20, null: false
      t.integer :volume, default: 0, null: false
      t.decimal :price, precision: 32, scale: 16, default: 0, null: false
      t.decimal :margin, precision: 32, scale: 16, default: 0, null: false
      t.decimal :credit, precision: 32, scale: 16, default: 0, null: false

      t.timestamps null: false
    end
    add_index "positions", %i[member_id market_id], unique: true
  end
end
