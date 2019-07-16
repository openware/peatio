class AddAccountingRecalculationProcedure < ActiveRecord::Migration[5.2]
  class EventSchedulerDisabledError < ActiveRecord::MigrationError
    def initialize
      super 'MySQL event scheduler is disabled. Please enable it before running this migration'
    end
  end

  def change
    reversible do |dir|
      dir.up do

        # Check that event_scheduler enabled.
        event_scheduler_status = execute <<-SQL
          SHOW VARIABLES
          WHERE VARIABLE_NAME = 'event_scheduler'
        SQL

        unless event_scheduler_status.to_h == { 'event_scheduler' => 'ON' }
          raise EventSchedulerDisabledError
        end

        # Drop stored procedure if it was defined before.
        execute <<-SQL
          DROP PROCEDURE IF EXISTS recalculate_accounts;
        SQL

        # Define stored procedure.
        execute <<-SQL
          CREATE PROCEDURE recalculate_accounts()
          BEGIN

            UPDATE accounts SET
            accounts.balance =
            (
              SELECT IFNULL(SUM(credit) - SUM(debit), 0) FROM liabilities
              WHERE liabilities.member_id = accounts.member_id AND liabilities.currency_id = accounts.currency_id AND liabilities.code
                IN (SELECT code FROM operations_accounts WHERE type = 'liability' AND kind = 'main')
            ),
            accounts.locked =
            (
              SELECT IFNULL(SUM(credit) - SUM(debit), 0) FROM liabilities
              WHERE liabilities.member_id = accounts.member_id AND liabilities.currency_id = accounts.currency_id AND liabilities.code
                IN (SELECT code FROM operations_accounts WHERE type = 'liability' AND kind = 'locked')
            ),
            updated_at = NOW();
          END
        SQL

        # Add event which recalculates account balances using liability history.
        execute <<-SQL
          CREATE EVENT accounts_secondly
            ON SCHEDULE
              EVERY 1 SECOND
            COMMENT 'Each second recalculate account balances.'
            DO
              CALL recalculate_accounts();
        SQL
      end

      dir.down do
        # Drop stored procedure for account balances recalculation.
        execute <<-SQL
          DROP PROCEDURE IF EXISTS recalculate_accounts;
        SQL

        # Drop account secondly recalculation event.
        execute <<-SQL
          DROP EVENT IF EXISTS acc_secondly
        SQL
      end
    end
  end
end
