class RemoveCurrencyFromPaymentAddresses < ActiveRecord::Migration
  def change
    remove_column :payment_addresses, :currency
  end
end
