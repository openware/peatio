class CreateUpstreams < ActiveRecord::Migration
  def change
    create_table :upstreams do |t|
      t.string :provider, limit: 32, null: false, index: {unique: true}
      t.integer :enabled, limit: 1, null: false, default: 0
      t.string :api_secret
      t.string :api_key
      t.integer :timeout, limit: 5, default: 0

      t.timestamps null: false
    end

    add_column :markets, :upstream_id, :integer, after: :id, null: true, index: true
  end
end
