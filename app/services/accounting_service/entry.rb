# encoding: UTF-8
# frozen_string_literal: true

module AccountingService
  class Entry
    attr_accessor :reference, :debits, :credits

    def initialize(reference:, debits:, credits:)
      @reference = reference
      @debits = debits
      @credits = credits
    end

    def save!
      validate!
      operations =
        debits.map do |debit|
          Operation.create!(
            debit: debit[:amount],
            account_id: debit[:account_id]
          )
        end
      operations <<
        credits.map do |credit|
          Operation.create!(
            credit: credit[:amount],
            account_id: credit[:account_id]
          )
        end
    end

    def validate!
      debit_sum = debits.sum { |d| d[:amount] }
      credit_sum = credits.sum { |d| d[:amount] }
      unless debit_sum == credit_sum
        raise Error, 'Debit amount sum doesn\'t equal to credit amount sum.'
      end
    end

    class << self
      def create!(reference:, debits:, credits:)
        new(reference: reference, debits: debits, credits: credits).save!
      end
    end
  end
end
