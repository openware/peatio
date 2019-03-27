# encoding: UTF-8
# frozen_string_literal: true

module LiabilityHistoryService
  class << self
    def fetch_new_history

      # fetch trade history

      sql = 'INSERT INTO liabilities_history (liability_id, member_id, market_id, currency_id, operation_type, operation_id, debit, credit, fee, fee_currency_id, price, side, operation_date, balance, created_at, updated_at)'\
           ' SELECT ANY_VALUE(l.id), l.member_id, ANY_VALUE(t.market_id), l.currency_id, l.reference_type, l.reference_id, SUM(l.debit), SUM(l.credit), MAX(r.credit) AS fee, ANY_VALUE(r.currency_id), ANY_VALUE(t.price), ANY_VALUE(IF(t.ask_member_id = l.member_id, "ask", "bid")) AS side, ANY_VALUE(t.created_at), ANY_VALUE((SELECT SUM(l1.credit - l1.debit) FROM liabilities AS l1 WHERE l1.member_id = l.member_id AND l1.currency_id = l.currency_id AND l1.id <= l.id)) AS balance, NOW(), NOW()'\
           ' FROM liabilities AS l'\
           ' INNER JOIN trades AS t ON (t.id = l.reference_id AND l.reference_type = "Trade")'\
           ' LEFT JOIN liabilities_history ON liabilities_history.liability_id = l.id'\
           ' LEFT JOIN revenues AS r ON r.id = l.revenue_id'\
           ' WHERE liabilities_history.id IS NULL AND (NOT EXISTS(SELECT lh.id FROM liabilities_history AS lh WHERE lh.member_id = l.member_id AND lh.currency_id = l.currency_id AND lh.operation_type = l.reference_type AND lh.operation_id = l.reference_id))'\
           ' GROUP BY l.member_id, l.currency_id, l.reference_type, l.reference_id'

      ActiveRecord::Base.connection.execute(sql)

      # fetch deposit history

      sql = 'INSERT INTO liabilities_history (liability_id, member_id, currency_id, operation_type, operation_id, debit, credit, fee, fee_currency_id, txid, state, operation_date, balance, tx_height, created_at, updated_at)'\
           ' SELECT l.id, l.member_id, l.currency_id, l.reference_type, l.reference_id, l.debit, l.credit, d.fee, l.currency_id AS fee_currency_id, d.txid, d.aasm_state, d.created_at, (SELECT SUM(l1.credit - l1.debit) FROM liabilities AS l1 WHERE l1.member_id = l.member_id AND l1.currency_id = l.currency_id AND l1.id <= l.id) AS balance, ANY_VALUE(b.min_confirmations), NOW(), NOW()'\
           ' FROM liabilities AS l'\
           ' INNER JOIN deposits AS d ON (d.id = l.reference_id AND l.reference_type = "Deposit")'\
           ' LEFT JOIN liabilities_history ON liabilities_history.liability_id = l.id'\
           ' LEFT JOIN currencies AS c ON c.id = l.currency_id'\
           ' LEFT JOIN blockchains AS b ON b.key = c.blockchain_key'\
           ' WHERE liabilities_history.id IS NULL;'

      ActiveRecord::Base.connection.execute(sql)

      # fetch withdraw history

      sql = 'INSERT INTO liabilities_history (liability_id, member_id, currency_id, operation_type, operation_id, debit, credit, fee, fee_currency_id, rid, txid, state, note, operation_date, balance, tx_height, created_at, updated_at)'\
           ' SELECT ANY_VALUE(l.id), l.member_id, l.currency_id, l.reference_type, l.reference_id, MAX(l.debit), MIN(l.credit), ANY_VALUE(w.fee), ANY_VALUE(l.currency_id), ANY_VALUE(w.rid), ANY_VALUE(w.txid), ANY_VALUE(w.aasm_state), ANY_VALUE(w.note), ANY_VALUE(w.created_at), MIN((SELECT SUM(l1.credit - l1.debit) FROM liabilities AS l1 WHERE l1.member_id = l.member_id AND l1.currency_id = l.currency_id AND l1.id <= l.id)) AS balance, ANY_VALUE(b.min_confirmations), NOW(), NOW()'\
           ' FROM liabilities AS l'\
           ' INNER JOIN withdraws AS w ON (w.id = l.reference_id AND l.reference_type = "Withdraw") '\
           ' LEFT JOIN liabilities_history ON liabilities_history.liability_id = l.id'\
           ' LEFT JOIN currencies AS c ON c.id = l.currency_id'\
           ' LEFT JOIN blockchains AS b ON b.key = c.blockchain_key'\
           ' WHERE liabilities_history.id IS NULL AND (NOT EXISTS(SELECT lh.id FROM liabilities_history AS lh WHERE lh.member_id = l.member_id AND lh.currency_id = l.currency_id AND lh.operation_type = l.reference_type AND lh.operation_id = l.reference_id))'\
           ' GROUP BY l.member_id, l.currency_id, l.reference_type, l.reference_id;'

      ActiveRecord::Base.connection.execute(sql)

      # update deposit state

      sql = 'UPDATE liabilities_history AS lh'\
           ' INNER JOIN deposits AS d ON (lh.operation_type = "Deposit" AND d.id = lh.operation_id AND d.aasm_state != lh.state)'\
           ' SET lh.state = d.aasm_state'

      ActiveRecord::Base.connection.execute(sql)

      # update withdraw state

      sql = 'UPDATE liabilities_history AS lh'\
           ' INNER JOIN withdraws AS w ON (lh.operation_type = "Withdraw" AND w.id = lh.operation_id AND w.aasm_state != lh.state)'\
           ' SET lh.state = w.aasm_state'

      ActiveRecord::Base.connection.execute(sql)
    end

  end
end
