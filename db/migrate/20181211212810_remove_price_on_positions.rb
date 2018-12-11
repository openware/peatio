class RemovePriceOnPositions < ActiveRecord::Migration
  def up
    remove_column :positions, :price
  end

  def down 
     add_column :positions, :price, :decimal, precision: 32, scale: 16, default: 0, null: false
  end    
end
