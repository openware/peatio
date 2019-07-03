# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      module Entities
        class Withdraw < Base
          expose(
            :id,
            documentation: {
              type: Integer,
              desc: 'The withdrawal id.'
            }
          )

          expose(
            :member_id,
            as: :member,
            documentation: {
              type: String,
              desc: 'The member id.'
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
            :account_id,
            as: :account,
            documentation: {
              type: String,
              desc: 'The account code.'
            }
          )

          expose(
            :block_number,
            documentation: {
              type: Integer,
              desc: 'The withdraw block_number.'
            },
            if: ->(w) { w.coin? }
          )

          expose(
            :type,
            documentation: {
              type: String,
              desc: 'The withdrawal type.'
            }
          ) { |w| w.fiat? ? :fiat : :coin }

          expose(
            :amount,
            documentation: {
              type: BigDecimal,
              desc: 'The withdrawal amount.'
            }
          )

          expose(
            :sum,
            documentation: {
              type: BigDecimal,
              desc: 'The withdrawal sum.'
            }
          )

          expose(
            :fee,
            documentation: {
              type: BigDecimal,
              desc: 'The exchange fee.'
            }
          )

          expose(
            :txid,
            as: :blockchain_txid,
            documentation: {
              type: String,
              desc: 'The withdrawal transaction id.'
            },
            if: ->(w) { w.coin? }
          )

          expose(
            :rid,
            documentation: {
              type: String,
              desc: 'The beneficiary ID or wallet address on the Blockchain.'
            },
            if: ->(w) { w.coin? }
          )

          expose(
            :aasm_state,
            as: :state,
            documentation: {
              type: String,
              desc: 'The withdrawal state.'
            }
          )

          expose(
            :confirmations,
            if: ->(w) { w.coin? },
            documentation: {
              type: Integer,
              desc: 'Number of confirmations.'
            }
          )

          expose(
            :tid,
            documentation: {
              type: String,
              desc: 'Withdraw tid.'
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
            :created_at,
            :updated_at,
            format_with: :iso8601,
            documentation: {
              type: String,
              desc: 'The datetimes for the withdrawal.'
            }
          )

          expose(
            :completed_at,
            as: :done_at,
            format_with: :iso8601,
            documentation: {
              type: String,
              desc: 'The datetime when withdraw was completed.'
            },
            if: ->(w) { w.completed? }
          )
        end
      end
    end
  end
end
