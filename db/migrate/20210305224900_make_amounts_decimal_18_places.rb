# frozen_string_literal: true

class MakeAmountsDecimal18Places < ActiveRecord::Migration[5.2]
  def change
    # Accounts
    change_column :accounts, :balance, :decimal,
                  precision: 34, scale: 18, null: false,
                  default: '0.000000000000000000'
    change_column :accounts, :locked, :decimal,
                  precision: 34, scale: 18, null: false,
                  default: '0.000000000000000000'
    # Assets
    change_column :assets, :debit, :decimal,
                  precision: 34, scale: 18, null: false,
                  default: '0.000000000000000000'
    change_column :assets, :credit, :decimal,
                  precision: 34, scale: 18, null: false,
                  default: '0.000000000000000000'
    # Currencies
    change_column :currencies, :deposit_fee, :decimal,
                  precision: 34, scale: 18, null: false,
                  default: '0.000000000000000000'
    change_column :currencies, :min_deposit_amount, :decimal,
                  precision: 34, scale: 18, null: false,
                  default: '0.000000000000000000'
    change_column :currencies, :min_collection_amount, :decimal,
                  precision: 34, scale: 18, null: false,
                  default: '0.000000000000000000'
    change_column :currencies, :withdraw_fee, :decimal,
                  precision: 34, scale: 18, null: false,
                  default: '0.000000000000000000'
    change_column :currencies, :min_withdraw_amount, :decimal,
                  precision: 34, scale: 18, null: false,
                  default: '0.000000000000000000'
    change_column :currencies, :withdraw_limit_24h, :decimal,
                  precision: 34, scale: 18, null: false,
                  default: '0.000000000000000000'
    change_column :currencies, :withdraw_limit_72h, :decimal,
                  precision: 34, scale: 18, null: false,
                  default: '0.000000000000000000'
    # Deposits
    change_column :deposits, :amount, :decimal,
                  precision: 34, scale: 18, null: false
    change_column :deposits, :fee, :decimal,
                  precision: 34, scale: 18, null: false
    # Expenses
    change_column :expenses, :debit, :decimal,
                  precision: 34, scale: 18, null: false,
                  default: '0.000000000000000000'
    change_column :expenses, :credit, :decimal,
                  precision: 34, scale: 18, null: false,
                  default: '0.000000000000000000'
    # Liabilities
    change_column :liabilities, :debit, :decimal,
                  precision: 34, scale: 18, null: false,
                  default: '0.000000000000000000'
    change_column :liabilities, :credit, :decimal,
                  precision: 34, scale: 18, null: false,
                  default: '0.000000000000000000'
    # Markets
    change_column :markets, :min_ask_price, :decimal,
                  precision: 34, scale: 18, null: false,
                  default: '0.000000000000000000'
    change_column :markets, :max_bid_price, :decimal,
                  precision: 34, scale: 18, null: false,
                  default: '0.000000000000000000'
    change_column :markets, :min_ask_amount, :decimal,
                  precision: 34, scale: 18, null: false,
                  default: '0.000000000000000000'
    change_column :markets, :min_bid_amount, :decimal,
                  precision: 34, scale: 18, null: false,
                  default: '0.000000000000000000'
    # Orders
    change_column :orders, :price, :decimal,
                  precision: 34, scale: 18, null: false
    change_column :orders, :volume, :decimal,
                  precision: 34, scale: 18, null: false
    change_column :orders, :origin_volume, :decimal,
                  precision: 34, scale: 18, null: false
    change_column :orders, :fee, :decimal,
                  precision: 34, scale: 18, null: false,
                  default: '0.000000000000000000'
    change_column :orders, :locked, :decimal,
                  precision: 34, scale: 18, null: false,
                  default: '0.000000000000000000'
    change_column :orders, :origin_locked, :decimal,
                  precision: 34, scale: 18, null: false,
                  default: '0.000000000000000000'
    change_column :orders, :funds_received, :decimal,
                  precision: 34, scale: 18, null: false,
                  default: '0.000000000000000000'
    # Revenues
    change_column :revenues, :debit, :decimal,
                  precision: 34, scale: 18, null: false,
                  default: '0.000000000000000000'
    change_column :revenues, :credit, :decimal,
                  precision: 34, scale: 18, null: false,
                  default: '0.000000000000000000'
    # Trades
    change_column :trades, :price, :decimal,
                  precision: 34, scale: 18, null: false
    change_column :trades, :volume, :decimal,
                  precision: 34, scale: 18, null: false
    change_column :trades, :funds, :decimal,
                  precision: 34, scale: 18, null: false
    # Wallets
    change_column :wallets, :max_balance, :decimal,
                  precision: 34, scale: 18, null: false,
                  default: '0.000000000000000000'
    # Withdraws
    change_column :withdraws, :amount, :decimal,
                  precision: 34, scale: 18, null: false
    change_column :withdraws, :fee, :decimal,
                  precision: 34, scale: 18, null: false
    change_column :withdraws, :sum, :decimal,
                  precision: 34, scale: 18, null: false
  end
end
