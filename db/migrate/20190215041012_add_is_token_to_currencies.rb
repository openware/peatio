class AddIsTokenToCurrencies < ActiveRecord::Migration
  def change
    add_column :currencies, :is_token, :boolean, after: :type, default: false
  end
end
