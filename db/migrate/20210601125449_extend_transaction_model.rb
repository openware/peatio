class ExtendTransactionModel < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :blockchain_key, :string, after: :currency_id
    add_column :transactions, :kind, :string, after: :currency_id
    add_column :transactions, :fee, :decimal, precision: 32, scale: 16, after: :amount
    add_column :transactions, :fee_currency_id, :string, after: :currency_id, null: false
  end
end
