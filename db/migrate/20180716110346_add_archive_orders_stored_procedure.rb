class AddArchiveOrdersStoredProcedure < ActiveRecord::Migration
  def self.up
    execute 'DROP procedure IF EXISTS `archive_orders`;'
    execute <<-SQL
    CREATE PROCEDURE archive_orders ()
    BEGIN
    SET @prepare_table = CONCAT('CREATE TABLE IF NOT EXISTS ', @table_name, ' SELECT * FROM orders WHERE 1=0');
    PREPARE create_table from @prepare_table;
    EXECUTE create_table;
    IF NOT EXISTS (SELECT k.COLUMN_NAME
        FROM information_schema.table_constraints t
        LEFT JOIN information_schema.key_column_usage k
        USING(constraint_name,table_schema,table_name)
        WHERE t.constraint_type='PRIMARY KEY'
        AND t.table_schema = DATABASE()
        AND t.table_name = @table_name) THEN
          SET @prepare_pk = CONCAT('ALTER TABLE ', @table_name, ' ADD PRIMARY KEY(id)');
          PREPARE create_pk from @prepare_pk;
          EXECUTE create_pk;
        END IF;

        SET @insert_date = CONCAT('INSERT INTO ', @table_name,
        ' SELECT * FROM orders WHERE DATE(updated_at) < ', CURDATE() - INTERVAL 2 DAY,
        ' AND state = 200' );
        PREPARE insert_stmt from @insert_date;
        EXECUTE insert_stmt ;
    END
    SQL

  end

  def self.down
    sql = 'DROP procedure IF EXISTS `archive_orders`;'
    execute sql
  end
end
