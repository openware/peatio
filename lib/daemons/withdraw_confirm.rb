# encoding: UTF-8
# frozen_string_literal: true

require File.join(ENV.fetch('RAILS_ROOT'), 'config', 'environment')

running = true
Signal.trap(:TERM) { running = false }

while running
  Withdraw.confirming.order(created_at: :asc).map(&:try_to_confirm!)
  sleep 5
end
