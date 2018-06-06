# encoding: UTF-8
# frozen_string_literal: true

require File.join(ENV.fetch('RAILS_ROOT'), 'config', 'environment')

running = true
Signal.trap(:TERM) { running = false }

while running
  Withdraw.succeed.order(creted_at: :asc).each do |w|
    next if w.txid.blank?

  end

  sleep 5
end
