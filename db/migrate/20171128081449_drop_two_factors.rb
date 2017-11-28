class DropTwoFactors < ActiveRecord::Migration
  def change
    drop_table :two_factors
  end
end
