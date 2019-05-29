class CreateTriggers < ActiveRecord::Migration[5.2]
  def change
    create_table :triggers do |t|
      t.references :order, null: false, index: true
      t.decimal    :price, null: false, default: 0, precision: 32, scale: 16
      t.timestamps
    end
  end
end
