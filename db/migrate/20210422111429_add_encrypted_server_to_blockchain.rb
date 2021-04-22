class AddEncryptedServerToBlockchain < ActiveRecord::Migration[5.2]
  def up
    server = Blockchain.pluck(:id, :server)

    remove_column :blockchains, :server
    add_column :blockchains, :server_encrypted , :string, limit: 1024, after: :client

    server.each do |s|
      atr = Blockchain.__vault_attributes[:server]
      enc = Vault::Rails.encrypt(atr[:path], atr[:key], s[1])
      execute "UPDATE blockchain SET #{atr[:encrypted_column]} = '#{enc}' WHERE id = #{s[0]}"
    end
  end

  def downcase
    server = Blockchain.pluck(:id, :server_encrypted)

    add_column :blockchains, :server, :string, limit: 1000, default: '', null: false, after: :client
    remove_column :blockchains, :server_encrypted , :string, limit: 1024, after: :client

    server.each do |s|
      atr = Blockchain.__vault_attributes[:server]
      dec = Vault::Rails.decrypt(atr[:path], atr[:key], s[1])
      execute "UPDATE blockchains SET server = '#{dec}' WHERE id = #{s[0]}"
    end
  end
end
