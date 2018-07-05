# encoding: UTF-8
# frozen_string_literal: true

require File.join(ENV.fetch('RAILS_ROOT'), 'config', 'environment')

running = true
Signal.trap(:TERM) { running = false }

while running
  Withdraws::Coin.confirming.includes(:currency).find_each(batch_size: 10) do |withdraw|
    confirmations = withdraw.currency.api.load_deposit!(withdraw.txid).fetch(:confirmations)
    next if confirmations.zero? || confirmations == withdraw.confirmations
    withdraw.with_lock do
      break unless withdraw.confirming?
      withdraw.confirmations = confirmations
      if withdraw.confirmations >= withdraw.currency.withdraw_confirmations
        withdraw.success
      end
      withdraw.save!
    end
  rescue StandardError
    Rails.logger.info { "Failed to process #{withdraw.currency.code.upcase} withdrawal with #{withdraw.txid} txid." }
  end
  Kernel.sleep 5
end
