class AddBlockchainKeyForMultiCurrency < ActiveRecord::Migration[5.2]
  def change
    %i[description warning protocol].each do |t|
      add_column :blockchains, t, :string, after: :status
    end
    add_column :payment_addresses, :blockchain_key, :string, after: :wallet_id
    %i[deposits withdraws].each do |t|
      add_column t, :blockchain_key, :string, after: :currency_id
    end

    # For existing payment address
    PaymentAddress.all.each { |payment| payment.update(blockchain_key: payment.wallet.blockchain_key) }
  end
end
