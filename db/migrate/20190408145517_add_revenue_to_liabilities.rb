class AddRevenueToLiabilities < ActiveRecord::Migration[5.2]
  def change
    add_column :liabilities, :revenue_id, :integer, foreign_key: true, after: :member_id
  end
end
