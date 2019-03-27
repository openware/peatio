# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Entities
      class LiabilityHistory < Base

        expose(
          :operation_id,
          as: :id,
          documentation: {
            type: Integer,
            desc: 'Operation id.'
          }
        )

        expose(
          :type,
          documentation: {
            type: String,
            desc: 'Operation type.'
          }
        ) { |history| history.operation_type.downcase }

        expose(
          :currency_id,
          as: :currency,
          documentation: {
            type: String,
            desc: 'Operation currency.'
          }
        )

        expose(
          :amount,
          documentation: {
            type: BigDecimal,
            desc: 'Transaction amount.'
          }
        ) do |operation|
            operation.credit - operation.debit
          end

        expose(
          :state,
          documentation: {
            type: String,
            desc: 'Operation state.'
          }
        )

        expose(
          :side,
          documentation: {
            type: String,
            desc: 'Trade side.'
          }
        )

        expose(
          :market_id,
          as: :market,
          documentation: {
            type: String,
            desc: 'Trade market.'
          }
        )

        expose(
          :price,
          documentation: {
            type: BigDecimal,
            desc: 'Trade price.'
          }
        )

        expose(
          :fee,
          documentation: {
            type: BigDecimal,
            desc: 'Operation fee.'
          }
        ) do |operation|
            operation.fee.nil? ? 0 : operation.fee
          end

        expose(
          :fee_currency_id,
          as: :fee_currency,
          documentation: {
            type: String,
            desc: 'Currency which was used for paying operation fees.'
          }
        )

        expose(
          :rid,
          documentation: {
            type: String,
            desc: 'The beneficiary ID or wallet address on the Blockchain.'
          }
        )

        expose(
          :txid,
          documentation: {
            type: String,
            desc: 'Transaction id.'
          }
        )

        expose(
          :note,
          documentation: {
            type: String,
            desc: 'Withdraw note.'
          }
        )

        expose(
          :tx_height,
          documentation: {
            type: Integer,
            desc: 'Height of the operation.'
          }
        )

        expose(
          :operation_confirmations,
          as: :confirmations,
          documentation: {
            type: Integer,
            desc: 'Current height of the operation.'
          }
        )

        expose(
          :operation_date,
          as: :created_at,
          documentation: {
            type: :iso8601,
            desc: 'The datetime for operation.'
          }
        )

        expose(
          :balance,
          documentation: {
            type: BigDecimal,
            desc: 'Balance after operation.'
          }
        )
      end
    end
  end
end
