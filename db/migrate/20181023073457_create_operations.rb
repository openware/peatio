class CreateOperations < ActiveRecord::Migration
  def change
    create_table :operations do |t|
      t.integer     :account_id, null: false, index: true, foreign_key: true
      t.references  :reference,  null: false, index: true, polymorphic: true
      t.decimal     :debit,      null: false, default: 0, precision: 32, scale: 16
      t.decimal     :credit,     null: false, default: 0, precision: 32, scale: 16

      t.timestamps null: false
    end
  end
end
