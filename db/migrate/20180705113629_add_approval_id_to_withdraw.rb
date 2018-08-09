class AddApprovalIdToWithdraw < ActiveRecord::Migration
  def change
    add_column :withdraws, :approval_id, :string, limit: 64, after: :rid
  end
end
