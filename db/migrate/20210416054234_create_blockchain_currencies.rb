class CreateBlockchainCurrencies < ActiveRecord::Migration[5.2]
  def change
    create_table :blockchain_currencies do |t|
      t.string :currency_id, foreign_key: true, class: 'Currency'
      t.string :blockchain_key, foreign_key: true, class: 'Blockchain'
      t.decimal :deposit_fee, precision: 32, scale: 16, default: 0, null: false
      t.decimal :min_deposit_amount, precision: 32, scale: 16, default: 0, null: false
      t.decimal :min_collection_amount, precision: 32, scale: 16, default: 0, null: false
      t.decimal :withdraw_fee, precision: 32, scale: 16, default: 0, null: false
      t.decimal :min_withdraw_amount, precision: 32, scale: 16, default: 0, null: false
      t.timestamps
    end
  end
end
