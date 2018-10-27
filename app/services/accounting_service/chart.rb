# encoding: UTF-8
# frozen_string_literal: true

module AccountingService
  # Chart is singleton class.
  class Chart

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

    CHART = [
      { code:           201,
        type:           :liabilities,
        kind:           :main,
        currency_type:  :fiat,
        description:    'Main Fiat Liabilities Account',
        scope:          %i[member]
      },
      { code:           202,
        type:           :liabilities,
        kind:           :main,
        currency_type:  :coin,
        description:    'Main Crypto Liabilities Account',
        scope:          %i[member]
    },
      { code:           211,
        type:           :liabilities,
        kind:           :locked,
        currency_type:  :fiat,
        description:    'Locked Fiat Liabilities Account',
        scope:          %i[member]
      },
      { code:           212,
        type:           :liabilities,
        kind:           :locked,
        currency_type:  :coin,
        description:    'Locked Crypto Liabilities Account',
        scope:          %i[member]
      }
    ].map { |h| OpenStruct.new(h) }

    attr_accessor :chart

    def initialize(owner:, currency_id:)
      @chart = chart_for(owner, currency_id)
    end

    def codes(options={})
      chart
        .select { |entry| entry.to_h.merge(options) == entry.to_h }
        .map(&:code)
    end

    private

    def chart_for(owner, currency_id)
      currency = Currency.find(currency_id)
      CHART.select do |entry|
        owner.type.in?(entry.scope)\
        && entry.currency_type == currency.type.to_sym
      end
    end
  end
end
