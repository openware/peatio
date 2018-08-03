class RemoveUrlsFromCurrencies < ActiveRecord::Migration
  def change
    remove_column :currencies, :wallet_url_template, :string
    remove_column :currencies, :transaction_url_template, :string
  end
end
