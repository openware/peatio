class CurrencyRefactorPaymentAddresses < ActiveRecord::Migration
  def change
    remove_column :payment_addresses, :currency, :integer
    add_column :payment_addresses, :currency_id, :integer, unsigned: true
  end
end
