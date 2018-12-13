class AddBaseToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :base, :string, default: 'spot'
  end
end
