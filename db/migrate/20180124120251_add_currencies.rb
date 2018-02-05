class AddCurrencies < ActiveRecord::Migration
  def change
    create_table :currencies, :force => true do |t|
      t.string  :key,                      limit: 30, null: false
      t.string  :code,                     limit: 30, null: false, #uniq
      t.string  :name,                     limit: 30, null: false
      t.string  :symbol,                   limit: 1 #not null
      t.string  :type,                     limit: 30, null: false, default: 'coin'
      t.string  :json_rpc_endpoint,        limit: 200
      t.string  :rest_api_endpoint,        limit: 200
      t.string  :hot_wallet_address,       limit: 200, null: false, #remove
      t.string  :wallet_url_template,      limit: 200, null: false, #optional
      t.string  :transaction_url_template, limit: 200, null: false #optional
      t.decimal :quick_withdraw_limit,     precision: 23, scale: 10, unsigned: true, null: false, default: 0, #unsigned remove
      t.string  :options,                  limit: 1000, default: '{}', null: false
      t.boolean :visible,                  default: true, #null: false, index
      t.timestamps                         null: false
    end
  end
end
