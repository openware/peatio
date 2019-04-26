class AddSpreadToDeposit < ActiveRecord::Migration[5.2]
  def change
    add_column :deposits, :spread, :string,
               limit: 1000, default: '{}', after: :tid
  end
end
