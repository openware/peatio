class CreateLiabilitiesHistory < ActiveRecord::Migration[5.0]
  def change
    create_table :liabilities_history do |t|
      t.integer  :liability_id, null: false, foreign_key: true
      t.integer  :member_id, null: true, foreign_key: true
      t.string   :currency_id, null: false, foreign_key: true
      t.string   :market_id, null: true, foreign_key: true
      t.string   :operation_type, limit: 16
      t.integer  :operation_id
      t.decimal  :debit, null: false, default: 0, precision: 32, scale: 16
      t.decimal  :credit, null: false, default: 0, precision: 32, scale: 16
      t.decimal  :fee, precision: 32, scale: 16
      t.string   :fee_currency_id
      t.decimal  :price, precision: 32, scale: 16
      t.string   :side, limit: 16
      t.string   :rid
      t.string   :txid, limit: 255
      t.string   :state, limit: 16
      t.string   :note, limit: 256
      t.datetime :operation_date
      t.decimal  :balance, precision: 32, scale: 16
      t.integer  :tx_height

      t.timestamps null: false
    end

    add_index :liabilities_history, [:member_id, :operation_date]
  end
end
