class ChangeWalletStructure < ActiveRecord::Migration
  def change
    add_column :wallets, :settings, :json
  end
end
