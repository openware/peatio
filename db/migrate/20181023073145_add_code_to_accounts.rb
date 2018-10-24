class AddCodeToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :code, :integer, limit: 3, null: true, after: :currency_id
  end
end
