class CreateCurrenciesWallets < ActiveRecord::Migration[5.2]
  def change
    create_table :currencies_wallets do |t|
      t.string :currency_id
      t.string :wallet_id
    end

    add_index :currencies_wallets, %i[currency_id wallet_id], unique: true
    remove_column :payment_addresses, :currency_id
    remove_column :payment_addresses, :account_id
    remove_column :wallets, :currency_id
    add_reference :payment_addresses, :wallet, index: true
    add_reference :payment_addresses, :member, index: true
  end
end
