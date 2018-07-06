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
      api = withdraw.currency.api
      result = api.pending_approval(withdraw.approval_id)

      if result[:status] == 'approved'
        withdraw.whodunnit self.class.name do
          withdraw.txid = result[:txid]
          withdraw.success
          withdraw.save!
        end
      elsif result[:state] == 'rejected'
          withdraw.reject
      end
    rescue
      puts "Error on withdraw approval: #{$!}"
      puts $!.backtrace.join("\n")
    end
  end

  sleep 5
end
