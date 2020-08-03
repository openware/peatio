class CompactLiabilities < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        execute 'DROP procedure IF EXISTS `compact_liabilities`;'
        execute <<-SQL

        CREATE PROCEDURE `compact_liabilities`(
            IN min_date DATETIME,
            IN max_date DATETIME
        )
        BEGIN
            -- Liabilities Compaction
            CREATE TABLE IF NOT EXISTS `liabilities_tmp` LIKE `liabilities`;

            INSERT INTO `liabilities_tmp` SELECT * FROM `liabilities` WHERE `created_at` BETWEEN min_date AND max_date;

            DELETE FROM `liabilities` WHERE `created_at` BETWEEN min_date AND max_date;

            INSERT INTO `liabilities`
            SELECT NULL, code, currency_id, member_id, 'compact',
            DATE_FORMAT(max_date, "%Y%m%d"), SUM(debit), SUM(credit), NOW(), NOW() FROM `liabilities_tmp`
            WHERE `reference_type` = 'Order' AND `created_at` BETWEEN min_date AND max_date
            GROUP BY code, currency_id, member_id, DATE(`created_at`);

            DROP TABLE `liabilities_tmp`;

        END
        SQL
      end

      dir.down do
        sql = 'DROP procedure IF EXISTS `compact_liabilities`;'
        execute sql
      end
    end
  end
end
