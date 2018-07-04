module Services
  class Archive

    def table_exists?(table_name)
      res = ActiveRecord::Base.connection.execute("show tables like '#{table_name}'").first.present?
      puts "******* Skipping #{table_name.titleize} Backup Table. Already Exist ******" if res
      res
    end

    def call
      date = (Date.today - 1.day)
      date_start = date.beginning_of_month
      date_end = date.end_of_month
      order_table = "orders_#{date.strftime('%B_%Y')}".downcase
      trades_table = "trades_#{date.strftime('%B_%Y')}".downcase

      return false if (table_exists?(order_table) && table_exists?(trades_table))

      unless table_exists?(order_table)
        puts "******* Creating Order Table Form #{date_start} To #{date_end} ******"
        order_sql = "CREATE TABLE #{order_table} AS (SELECT * FROM orders WHERE DATE(created_at) BETWEEN '#{date_start}' AND '#{date_end}') ;"
        ActiveRecord::Base.connection.execute(order_sql)
        puts '******* Order Table Created ********'
      end

      unless table_exists?(trades_table)
        puts "******* Creating Trades Table Form #{date_start} To #{date_end} ********"
        trades_sql = "CREATE TABLE #{trades_table} AS (SELECT * FROM trades WHERE DATE(created_at) BETWEEN '#{date_start}' AND '#{date_end}') ;"
        ActiveRecord::Base.connection.execute(trades_sql)
        puts '******* Trades Table Created ********'
      end

      return true if (table_exists?(order_table) && table_exists?(trades_table))
    end
  end
end