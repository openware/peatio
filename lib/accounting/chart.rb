# encoding: UTF-8
# frozen_string_literal: true

module Accounting
  # Chart is singleton class.
  class Chart

    # Should be Chart::Entry.
    PLATFORM_ACCOUNTS = {
      #
      101 => 'Fiat Assets Account',
      102 => 'Crypto Assets Account',
      #
      310 => 'Fees Revenue Account',
      #
      570 => 'Blockchain Fees Expenses'
      #
    }

    MEMBER_ACCOUNTS = {
      201 => 'Fiat Liabilities Account',
      202 => 'Crypto Liabilities Account',

      211 => 'Locked Fiat Liabilities',
      212 => 'Locked Crypto Liabilities'
    }

    def chart
      PLATFORM_ACCOUNTS.merge(MEMBER_ACCOUNTS)
    end

    def codes
      chart.keys
    end

    class << self
      def codes_for(currency)
        currency.fiat? ? [201, 211] : [202, 212]
      end

      def deposit_codes
        [201, 202]
      end

      def locked_codes
        [211, 212]
      end
    end
  end
end
