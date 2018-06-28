# encoding: UTF-8
# frozen_string_literal: true

# Crontab to run rake task every month at 1am
# Use command crontab -e to edit crontab and add following command
# 0 1 1 * * /bin/bash -l -c 'cd ~/peatio && RAILS_ENV=production bundle exec rake archive:seed --silent'

namespace :archive do
  desc 'Archive order and trade tables.'
  task seed: :environment do
    date = (Date.today - 1.day)
    date_start = date.beginning_of_month
    date_end = date.end_of_month

    order_table_name = "orders_#{date.strftime('%B_%Y')}".downcase
    backup_order_table_exist = ActiveRecord::Base.connection.execute("show tables like '#{order_table_name}'").first.present?

    if backup_order_table_exist
      puts "----- Skipping Order Backup Table. Already Exist For Month #{date.strftime('%B')} -----"
    else
      puts "----- Creating Order Table Form #{date_start} To #{date_end} -----"
      order_sql = "CREATE TABLE #{order_table_name} AS (SELECT * FROM orders WHERE DATE(created_at) BETWEEN '#{date_start}' AND '#{date_end}') ;"
      ActiveRecord::Base.connection.execute(order_sql)
      puts '----- Order Table Created -----'
    end

    trades_table_name = "trades_#{date.strftime('%B_%Y')}".downcase
    backup_trade_table_exist = ActiveRecord::Base.connection.execute("show tables like '#{trades_table_name}'").first.present?

    if backup_trade_table_exist
      puts "----- Skipping Trade Backup Table. Already Exist For Month #{date.strftime('%B')} -----"
    else
      puts "----- Creating Trades Table Form #{date_start} To #{date_end} -----"
      trades_sql = "CREATE TABLE #{trades_table_name} AS (SELECT * FROM trades WHERE DATE(created_at) BETWEEN '#{date_start}' AND '#{date_end}') ;"
      ActiveRecord::Base.connection.execute(trades_sql)
      puts '----- Trades Table Created -----'
    end

  end
end


