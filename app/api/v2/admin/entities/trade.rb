# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      module Entities
        class Trade < API::V2::Entities::Trade
          unexpose(:side)
          unexpose(:order_id)

          expose(
            :ask_id,
            documentation: {
              type: String,
              desc: 'Trade ask order id.'
            }
          )

          expose(
            :bid_id,
            documentation: {
              type: String,
              desc: 'Trade bid order id.'
            }
          )

          expose(
            :ask_member_uid,
            documentation: {
              type: String,
              desc: 'Trade ask member uid.'
            }
          ) do |trade|
              trade.ask.member.uid
          end

          expose(
            :bid_member_uid,
            documentation: {
              type: String,
              desc: 'Trade bid member uid.'
            }
          ) do |trade|
            trade.bid.member.uid
          end

          expose(
            :taker_type,
            documentation: {
              type: String,
              desc: 'Trade taker order type (sell or buy).'
            }
          ) do |trade, _options|
              trade.ask_id > trade.bid_id ? :sell : :buy
          end
        end
      end
    end
  end
end
