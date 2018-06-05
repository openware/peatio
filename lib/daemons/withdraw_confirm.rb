# encoding: UTF-8
# frozen_string_literal: true

require File.join(ENV.fetch('RAILS_ROOT'), 'config', 'environment')

running = true
Signal.trap(:TERM) { running = false }

while running
  Withdraw.where(aasm_state: succeed).order(creted_at: :asc).find_each do |withdraw|
    next if withdraw.txid.blank?
    withdraw.currency.tap do |c|
      withdraw.with_lock do
        withdraw.confirm if c.api.load_deposit!(withdraw.txid).fetch(:confimations) >= c.withdraw_confirmations
      end
    end
  end

  sleep 5
end
