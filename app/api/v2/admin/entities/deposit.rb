# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      module Entities
        class Deposit < Base
          expose(
            :id,
            documentation: {
              type: Integer,
              desc: 'Unique deposit id.'
            }
          )

          expose(
            :currency_id,
            as: :currency,
            documentation: {
              type: String,
              desc: 'Deposit currency id.'
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
            :uid,
            documentation: {
              type: Integer,
              desc: 'Deposit member uid.'
            }
          )

          expose(
            :amount,
            format_with: :decimal,
            documentation: {
              type: BigDecimal,
              desc: 'Deposit amount.'
            }
          )

          expose(
            :fee,
            documentation: {
              type: BigDecimal,
              desc: 'Deposit fee.'
            }
          )

          expose(
            :txid,
            as: :blockchain_txid,
            documentation: {
              type: String,
              desc: 'Deposit transaction id.'
            },
            if: ->(deposit) { deposit.coin? }
          )

          expose(
            :confirmations,
            documentation: {
              type: Integer,
              desc: 'Number of deposit confirmations.'
            },
            if: ->(deposit) { deposit.coin? }
          )

          expose(
            :address,
            documentation: {
              type: String,
              desc: 'Deposit blockchain address.'
            },
            if: ->(deposit) { deposit.coin? }
          )

          expose(
            :txout,
            documentation: {
              type: Integer,
              desc: 'Deposit blockchain transaction output.'
            },
            if: ->(deposit) { deposit.coin? }
          )

          expose(
            :block_number,
            documentation: {
              type: Integer,
              desc: 'Deposit blockchain block number.'
            },
            if: ->(deposit) { deposit.coin? }
          )

          expose(
            :type,
            documentation: {
              type: String,
              desc: 'Deposit type (fiat or coin).'
            }
          ) { |d| d.fiat? ? :fiat : :coin }

          expose(
            :aasm_state,
            as: :state,
            documentation: {
              type: String,
              desc: 'Deposit state.'
            }
          )

          expose(
            :tid,
            documentation: {
              type: String,
              desc: 'Deposit tid.'
            }
          )

          expose(
            :spread,
            documentation: {
              type: String,
              desc: 'Deposit collection spread.'
            },
            if: -> (deposit) { !deposit.spread.empty? }
          )

          expose(
            :updated_at,
            format_with: :iso8601,
            documentation: {
              type: String,
              desc: 'The datetime when deposit was updated.'
            }
          )

          expose(
            :created_at,
            format_with: :iso8601,
            documentation: {
              type: String,
              desc: 'The datetime when deposit was created.'
            }
          )

          expose(
            :completed_at,
            as: :done_at,
            format_with: :iso8601,
            documentation: {
              type: String,
              desc: 'The datetime when deposit was completed.'
            },
            if: ->(deposit) { deposit.completed? }
          )
        end
      end
    end
  end
end
