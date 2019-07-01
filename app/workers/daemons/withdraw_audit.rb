# encoding: UTF-8
# frozen_string_literal: true

module Workers
  module Daemons
    class WithdrawAudit < Base

      self.sleep_time = 5

      def process
        Withdraw.submitted.each do |withdraw|
          withdraw.audit!
        end
      end
    end
  end
end
