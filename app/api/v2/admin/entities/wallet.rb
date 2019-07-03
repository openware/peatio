# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      module Entities
        class Wallet < Base

          expose(
            :id,
            documentation:{
              type: Integer,
              desc: 'Unique wallet id.'
            }
          )

          expose(
            :name,
            documentation: {
                type: String,
                desc: 'Wallet name.'
            }
          )

          expose(
            :kind,
            documentation: {
                type: String,
                desc: "Kind of wallet 'deposit','fee','hot','warm' or 'cold'."
            }
          )

          expose(
            :currency_id,
            documentation: {
                type: String,
                desc: 'Wallet currency id.'
            }
          )

          expose(
            :address,
            documentation: {
                type: String,
                desc: 'Wallet address.'
            }
          )

          expose(
            :gateway,
            documentation: {
                type: String,
                desc: 'Wallet gateway.'
            }
          )

          expose(
            :nsig,
            documentation: {
                type: Integer,
                desc: 'Wallet number of signatures.'
            }
          )

          expose(
            :max_balance,
            documentation: {
                type: BigDecimal,
                desc: 'Wallet max balance.'
            }
          )

          expose(
            :parent,
            documentation: {
                type: Integer,
                desc: 'Wallet parent.'
            }
          )

          expose(
            :blockchain_key,
            documentation: {
                type: String,
                desc: 'Wallet blockchain key.'
            }
          )

          expose(
            :status,
            documentation: {
                type: String,
                desc: 'Wallet status (active/disabled).'
            }
          )

          expose(
            :settings,
            documentation: {
              type: JSON,
              desc: 'Wallet settings.'
            }
          )

          expose(
            :created_at,
            format_with: :iso8601,
            documentation: {
              type: String,
              desc: 'Wallet created time in iso8601 format.'
            }
          )

          expose(
            :updated_at,
            format_with: :iso8601,
            documentation: {
              type: String,
              desc: 'Wallet updated time in iso8601 format.'
            }
          )
        end
      end
    end
  end
end
