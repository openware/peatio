class CreateAccountments < ActiveRecord::Migration
  def change
    create_table :accountments do |t|

      t.timestamps null: false
    end
  end
end
