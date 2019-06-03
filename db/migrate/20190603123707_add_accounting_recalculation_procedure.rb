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

           -- Flag which defines if all accounts in cursor are processed.
           DECLARE v_finished INTEGER DEFAULT 0;
          
           DECLARE id bigint DEFAULT 0;
           DECLARE currency_id varchar(10) DEFAULT "";
           DECLARE member_id bigint DEFAULT 0;
          
           -- Declare cursor for account id, currency_id and member_id.
           DEClARE account_cursor CURSOR FOR 
           SELECT accounts.id, accounts.currency_id, accounts.member_id
           FROM accounts;
           
           -- Declare NOT FOUND handler.
           DECLARE CONTINUE HANDLER
            FOR NOT FOUND SET v_finished = 1;
           
           OPEN account_cursor;
           
           accounts_loop: LOOP
           
           FETCH account_cursor INTO id, currency_id, member_id;
           
           -- Finish account loop if all accounts are processed.
           IF v_finished = 1 THEN
              LEAVE accounts_loop;
           END IF;
           
           -- Recalculate account balances based on liability history.
           UPDATE accounts SET
            accounts.balance =
            (
              SELECT IFNULL(SUM(credit) - SUM(debit), 0) FROM liabilities 
              WHERE liabilities.member_id = member_id AND liabilities.currency_id = currency_id AND liabilities.code IN (201,202)
            ),
            accounts.locked =
            (
              SELECT IFNULL(SUM(credit) - SUM(debit), 0) FROM liabilities 
              WHERE liabilities.member_id = member_id AND liabilities.currency_id = currency_id AND liabilities.code IN (211,212)
            ),
            updated_at = NOW()
            WHERE accounts.id = id;
           
           END LOOP accounts_loop;
           
           CLOSE account_cursor;
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
