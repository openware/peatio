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
            :maker_order_email,
            documentation: {
              type: String,
              desc: 'Trade maker member email.'
            }
          ) { |trade| trade.maker.email }

          expose(
            :maker_uid,
            documentation: {
              type: String,
              desc: 'Trade maker member uid.'
            }
          ) { |trade| trade.maker.uid }

          expose(
            :maker_fee,
            documentation: {
              type: BigDecimal,
              desc: 'Trade maker fee percentage.',
            },
            if: ->(object, options) { options[:extended] }
          ) { |trade| trade.maker_order.maker_fee }

          expose(
            :maker_fee_amount,
            documentation: {
              type: BigDecimal,
              desc: 'Trade maker fee amount.',
            }
          ) { |trade| fee_amount(trade, trade.maker_order) }

          expose(
            :maker_currency,
            documentation: {
              type: String,
              desc: 'Trade maker currency code.'
            }
          ) { |trade| trade.maker_order.currency.code }

          expose(
            :maker_order,
            using: API::V2::Admin::Entities::Order,
            if: ->(object, options) { options[:extended] }
          )

          expose(
            :taker_order_email,
            documentation: {
              type: String,
              desc: 'Trade taker member email.'
            }
          ) { |trade| trade.taker.email }

          expose(
            :taker_uid,
            documentation: {
              type: String,
              desc: 'Trade taker member uid.'
            }
          ) { |trade| trade.taker.uid }

          expose(
            :taker_currency,
            documentation: {
              type: String,
              desc: 'Trade taker currency code.'
            }
          ) { |trade| trade.taker_order.currency.code }

          expose(
            :taker_fee,
            documentation: {
              type: BigDecimal,
              desc: 'Trade taker fee percentage.',
            },
            if: ->(object, options) { options[:extended] }
          ) { |trade| trade.taker_order.taker_fee }

          expose(
            :taker_fee_amount,
            documentation: {
              type: BigDecimal,
              desc: 'Trade taker fee amount.',
            }
          ) { |trade| fee_amount(trade, trade.taker_order) }

          expose(
            :taker_order,
            using: API::V2::Admin::Entities::Order,
            if: ->(object, options) { options[:extended] }
          )

          def fee_amount(trade, order)
            trade.order_fee(order) * (order.side == 'buy' ? trade.amount : trade.total)
          end
        end
      end
    end
  end
end
