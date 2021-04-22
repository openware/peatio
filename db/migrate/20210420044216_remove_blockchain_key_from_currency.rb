class RemoveBlockchainKeyFromCurrency < ActiveRecord::Migration[5.2]
  def change
    remove_column :currencies, :blockchain_key
  end
end
