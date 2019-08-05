# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      module Entities
        class Operation < API::V2::Management::Entities::Operation
          expose(
            :id,
            documentation: {
              type: Integer,
              desc: 'Unique operation identifier in database.'
            }
          )

          expose(
            :credit,
            documentation: {
              type: String,
              desc: 'Operation credit amount.'
            }
          )

          expose(
            :debit,
            documentation: {
              type: String,
              desc: 'Operation debit amount.'
            }
          )

          expose(
            :reference_id,
            as: :rid,
            documentation: {
              type: String,
              desc: 'The id of operation reference.'
            }
          )
        end
      end
    end
  end
end
