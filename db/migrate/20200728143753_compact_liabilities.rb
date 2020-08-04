class CompactLiabilities < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        execute 'DROP procedure IF EXISTS `compact_orders`;'
        execute <<-SQL

        CREATE PROCEDURE `compact_orders`(
            IN min_date DATETIME,
            IN max_date DATETIME
        )
        BEGIN
            -- Liabilities Compaction
            DECLARE pointer INT;
            DECLARE counter INT;
            CREATE TABLE IF NOT EXISTS `liabilities_tmp` LIKE `liabilities`;

            INSERT INTO `liabilities_tmp` SELECT * FROM `liabilities` WHERE `created_at` BETWEEN min_date AND max_date;
            SELECT DATE_FORMAT(max_date, "%Y%m%d") INTO pointer;
            SELECT ROW_COUNT() INTO counter;

            DELETE FROM `liabilities` WHERE `created_at` BETWEEN min_date AND max_date;

            INSERT INTO `liabilities`
            SELECT NULL, code, currency_id, member_id, 'compact_orders',
            DATE_FORMAT(max_date, "%Y%m%d"), SUM(debit), SUM(credit), max_date, NOW() FROM `liabilities_tmp`
            WHERE `reference_type` = 'Order' AND `created_at` BETWEEN min_date AND max_date
            GROUP BY code, currency_id, member_id, DATE(`created_at`);

            DROP TABLE `liabilities_tmp`;
            SELECT pointer,counter;
        END
        SQL
      end

      dir.down do
        sql = 'DROP procedure IF EXISTS `compact_orders`;'
        execute sql
      end
    end
  end
end
