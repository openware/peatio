# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Entities
      class Transaction < Base
        expose(
          :id,
          documentation: {
            type: Integer,
            desc: 'Unique transaction id.'
          }
        )

        expose(
          :type,
          documentation: {
            type: String,
            desc: 'Transaction type.'
          }
        )

        expose(
          :currency_id,
          as: :currency,
          documentation: {
            type: String,
            desc: 'The currency code.'
          }
        )

        expose(
          :sum,
          as: :amount,
          documentation: {
            type: String,
            desc: 'Transaction amount'
          },
          safe: true
        )

        expose(
          :amount,
          format_with: :decimal,
          documentation: {
            type: BigDecimal,
            desc: 'Transaction amount.'
          },
          if: ->(transaction) { transaction.class.superclass.to_s == 'Deposit' }
        )

        expose(
          :fee,
          documentation: {
            type: BigDecimal,
            desc: 'Transaction fee.'
          }
        )

        expose(
          :txid,
          documentation: {
            type: String,
            desc: 'Transaction transaction id.'
          }
        )

        expose(
          :rid,
          documentation: {
            type: String,
            desc: 'The beneficiary ID or wallet address on the Blockchain.'
          },
          safe: true
        )

        expose(
          :aasm_state,
          as: :state,
          documentation: {
            type: String,
            desc: 'Transaction state.'
          }
        )

        expose(
          :confirmations,
          if: ->(transaction) { transaction.coin? },
          documentation: {
            type: Integer,
            desc: 'Number of confirmations.'
          }
        )

        expose(
          :created_at,
          :updated_at,
          format_with: :iso8601,
          documentation: {
            type: String,
            desc: 'The datetimes for transaction.'
          }
        )

        expose(
          :completed_at,
          format_with: :iso8601,
          documentation: {
            type: String,
            desc: 'The datetime when transaction was completed'
          }
        )

      end
    end
  end
end
