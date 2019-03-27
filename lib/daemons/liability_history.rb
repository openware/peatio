# encoding: UTF-8
# frozen_string_literal: true

require File.join(ENV.fetch('RAILS_ROOT'), 'config', 'environment')

running = true
Signal.trap(:TERM) { running = false }

while running
  LiabilityHistoryService.fetch_new_history
  Kernel.sleep 5
end
