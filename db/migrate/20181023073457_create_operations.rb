class CreateOperations < ActiveRecord::Migration
  def change
    create_table :operations do |t|
      t.belongs_to  :account, index: { unique: true }, foreign_key: true
      t.decimal     :debit,   null: false, default: 0, precision: 32, scale: 16
      t.decimal     :credit,  null: false, default: 0, precision: 32, scale: 16

      t.timestamps null: false
    end
  end
end
