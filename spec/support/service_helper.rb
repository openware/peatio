# encoding: UTF-8
# frozen_string_literal: true

def drop_archive_tables
  ActiveRecord::Base.connection.execute("drop table #{orders_table} ") if ActiveRecord::Base.connection.execute("show tables like '#{orders_table}'").first.present?
  ActiveRecord::Base.connection.execute("drop table #{trades_table} ") if ActiveRecord::Base.connection.execute("show tables like '#{trades_table}'").first.present?
end

def create_archive_tables
  ActiveRecord::Base.connection.execute(order_sql)
  ActiveRecord::Base.connection.execute(trades_sql)
end