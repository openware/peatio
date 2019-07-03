# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      module Entities
        class Blockchain < Base
          expose(
            :id,
            documentation:{
              type: Integer,
              desc: 'Unique blockchain id.'
            }
          )

          expose(
            :key,
            documentation:{
              type: String,
              desc: 'Unique blockchain key.'
            }
          )

          expose(
            :name,
            documentation:{
              type: String,
              desc: 'Unique blockchain name.'
            }
          )

          expose(
            :client,
            documentation:{
              type: String,
              desc: 'Unique blockchain client.'
            }
          )

          expose(
            :server,
            documentation:{
              type: String,
              desc: 'Blockchain server url.'
            }
          )

          expose(
            :height,
            documentation:{
              type: Integer,
              desc: 'The number of blocks preceding a particular block on blockchain.'
            }
          )

          expose(
            :step,
            documentation:{
              type: Integer,
              desc: 'Blockchain step.'
            }
          )

          expose(
            :explorer_address,
            documentation:{
              type: String,
              desc: 'Blockchain explorer address.'
            }
          )

          expose(
            :explorer_transaction,
            documentation:{
              type: String,
              desc: 'Blockchain explorer transaction.'
            }
          )

          expose(
            :min_confirmations,
            documentation:{
              type: Integer,
              desc: 'Blockchain min confirmations.'
            }
          )

          expose(
            :status,
            documentation:{
              type: String,
              desc: 'Blockchain status (active/disabled).'
            }
          )

          expose(
            :created_at,
            format_with: :iso8601,
            documentation: {
              type: String,
              desc: 'Blockchain created time in iso8601 format.'
            }
          )

          expose(
            :updated_at,
            format_with: :iso8601,
            documentation: {
              type: String,
              desc: 'Blockchain updated time in iso8601 format.'
            }
          )
        end
      end
    end
  end
end
