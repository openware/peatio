# encoding: UTF-8
# frozen_string_literal: true

require File.join(ENV.fetch('RAILS_ROOT'), 'config', 'environment')

$running = true
Signal.trap("TERM") do
  $running = false
end

while($running) do
  Withdraw.pending.each do |withdraw|
    begin
      wallet = Wallet.active.withdraw.find_by(currency_id: withdraw.currency_id, kind: :hot)
      unless wallet
        Rails.logger.warn { "Can't find active hot wallet for currency with code: #{withdraw.currency_id}."}
        return
      end

      result = WalletService[wallet].pending_approval(withdraw.approval_id)

      if result[:status] == 'approved'
        withdraw.txid = result[:txid]
        withdraw.dispatch
        withdraw.save!
      elsif result[:status] == 'rejected'
        withdraw.reject!
      end
    rescue
      puts "Error on withdraw approval: #{$!}"
      puts $!.backtrace.join("\n")
    end
  end

  sleep 5
end