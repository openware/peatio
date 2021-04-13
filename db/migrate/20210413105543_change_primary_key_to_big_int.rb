class ChangePrimaryKeyToBigInt < ActiveRecord::Migration[5.2]
  include ::PrimaryKeyMigration

  def up
    table_names = %w[accounts assets blockchains deposits expenses liabilities
                     members operations_accounts orders payment_addresses revenues
                     transfers trades transfers wallets withdraws]

    run_primary_key_migration("BIGINT(20)", "bigint", table_names)

    ActiveRecord::Base.transaction do
      change_column :accounts, :member_id, :bigint, null: false
      change_column :assets, :reference_id, :bigint
      change_column :deposits, :member_id, :bigint, null: false
      change_column :expenses, :reference_id, :bigint

      change_column :liabilities, :member_id, :bigint
      change_column :liabilities, :reference_id, :bigint

      change_column :orders, :member_id, :bigint, null: false
      change_column :payment_addresses, :account_id, :bigint, null: false

      change_column :revenues, :member_id, :bigint
      change_column :revenues, :reference_id, :bigint

      change_column :trades, :maker_order_id, :bigint, null: false
      change_column :trades, :taker_order_id, :bigint, null: false
      change_column :trades, :maker_id, :bigint, null: false
      change_column :trades, :taker_id, :bigint, null: false

      change_column :withdraws, :member_id, :bigint, null: false

      change_column :stats_member_pnl, :member_id, :bigint, null: false
    end
  end

  def down
    table_names = %w[accounts assets blockchains deposits expenses liabilities
                     members operations_accounts orders payment_addresses revenues
                     transfers trades transfers wallets withdraws]
    run_primary_key_migration("INT(11)", "int", table_names)

    ActiveRecord::Base.transaction do
      change_column :accounts, :member_id, :integer, null: false
      change_column :assets, :reference_id, :integer
      change_column :deposits, :member_id, :integer, null: false
      change_column :expenses, :reference_id, :integer

      change_column :liabilities, :member_id, :integer
      change_column :liabilities, :reference_id, :integer

      change_column :orders, :member_id, :integer, null: false
      change_column :payment_addresses, :account_id, :integer, null: false

      change_column :revenues, :member_id, :integer
      change_column :revenues, :reference_id, :integer

      change_column :trades, :maker_order_id, :integer, null: false
      change_column :trades, :taker_order_id, :integer, null: false
      change_column :trades, :maker_id, :integer, null: false
      change_column :trades, :taker_id, :integer, null: false

      change_column :withdraws, :member_id, :integer, null: false

      change_column :stats_member_pnl, :member_id, :integer, null: false
    end
  end
end
