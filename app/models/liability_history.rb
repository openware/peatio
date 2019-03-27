# frozen_string_literal: true

class LiabilityHistory < ActiveRecord::Base
  self.table_name = 'liabilities_history'

  belongs_to :liability

  def operation_confirmations
    if operation_type == 'Deposit'
      operation = Deposit.find_by(id: self.operation_id)
      operation.confirmations if operation.coin?
    elsif operation_type == 'Withdraw'
      operation = Withdraw.find_by(id: self.operation_id)
      operation.confirmations if operation.coin?
    end
  end
end

# == Schema Information
# Schema version: 20190408145517
#
# Table name: liabilities_history
#
#  id              :integer          not null, primary key
#  liability_id    :integer          not null
#  member_id       :integer
#  currency_id     :string(255)      not null
#  market_id       :string(255)
#  operation_type  :string(16)
#  operation_id    :integer
#  debit           :decimal(32, 16)  default(0.0), not null
#  credit          :decimal(32, 16)  default(0.0), not null
#  fee             :decimal(32, 16)
#  fee_currency_id :string(255)
#  price           :decimal(32, 16)
#  side            :string(16)
#  rid             :string(255)
#  txid            :string(255)
#  state           :string(16)
#  note            :string(256)
#  operation_date  :datetime
#  balance         :decimal(32, 16)
#  tx_height       :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_liabilities_history_on_member_id_and_operation_date  (member_id,operation_date)
#
