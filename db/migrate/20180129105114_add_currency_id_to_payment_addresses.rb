class AddCurrencyIdToPaymentAddresses < ActiveRecord::Migration
  def change
    add_column :payment_addresses, :currency_id, :integer, unsigned: true
  end
end
