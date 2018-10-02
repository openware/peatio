class CreateFees < ActiveRecord::Migration
  def change
    create_table :fees do |t|
      t.integer :fee_chargeable_id
      t.string  :fee_chargeable_type
      t.timestamps null: false
    end

    add_index :fees, [:fee_chargeable_type, :fee_chargeable_id]
  end
end
