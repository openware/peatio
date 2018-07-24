class AddArchiveOrdersStoredProcedure < ActiveRecord::Migration
  def self.up
    execute 'DROP procedure IF EXISTS `archive_orders`;'
    execute <<-SQL
    CREATE PROCEDURE archive_orders ()
    BEGIN
      SET @table_name = CONCAT('orders_', DATE_FORMAT(CURDATE(),'%Y%m'));
      SET @prepare_table = CONCAT('CREATE TABLE IF NOT EXISTS ', @table_name, ' SELECT * FROM orders WHERE 1=0');
      PREPARE create_table from @prepare_table;
      EXECUTE create_table;
      DEALLOCATE PREPARE create_table;
      SET @insert_date = CONCAT('INSERT INTO ', @table_name,
      ' SELECT * FROM orders WHERE DATE(updated_at) BETWEEN ', DATE_FORMAT(NOW() ,'%Y-%m-01'),
      ' AND ', CURDATE() - INTERVAL 1 DAY,
      ' AND state = 200' );
      PREPARE insert_stmt from @insert_date;
      EXECUTE insert_stmt;
      DEALLOCATE PREPARE insert_stmt;
      DELETE FROM orders WHERE DATE(updated_at) BETWEEN DATE_FORMAT(NOW() ,'%Y-%m-01') AND CURDATE() - INTERVAL 1 DAY AND state = 200;
    END
    SQL
  end

  def self.down
    sql = 'DROP procedure IF EXISTS `archive_orders`;'
    execute sql
  end
end
