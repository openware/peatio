#encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      module MarketParams
        extend ::Grape::API::Helpers

        params :create_market_params do
          requires :base_unit,
                   type: String,
                   values: { value: -> { ::Currency.ids }, message: 'admin.market.currency_doesnt_exist' },
                   desc: -> { API::V2::Admin::Entities::Market.documentation[:base_unit][:desc] }
          requires :quote_unit,
                   type: String,
                   values: { value: -> { ::Currency.ids }, message: 'admin.market.currency_doesnt_exist' },
                   desc: -> { API::V2::Admin::Entities::Market.documentation[:quote_unit][:desc] }
          requires :amount_precision,
                   type: { value: Integer, message: 'admin.market.non_integer_amount_precision' },
                   values: { value: -> (p){ p >= 0 }, message: 'admin.market.invalid_amount_precision' },
                   default: 0,
                   desc: -> { API::V2::Admin::Entities::Market.documentation[:amount_precision][:desc] }
          requires :price_precision,
                   type: { value: Integer, message: 'admin.market.non_integer_price_precision' },
                   values: { value: -> (p){ p >= 0 }, message: 'admin.market.invalid_price_precision' },
                   default: 0,
                   desc: -> { API::V2::Admin::Entities::Market.documentation[:price_precision][:desc] }
          requires :min_price,
                   type: { value: BigDecimal, message: 'admin.market.non_decimal_min_price' },
                   values: { value: -> (p){ p >= 0 }, message: 'admin.market.invalid_min_price' },
                   default: 0.0,
                   desc: -> { API::V2::Admin::Entities::Market.documentation[:min_price][:desc] }
          optional :max_price,
                   type: { value: BigDecimal, message: 'admin.market.non_decimal_max_price' },
                   values: { value: -> (p){ p >= 0 }, message: 'admin.market.invalid_max_price' },
                   default: 0.0,
                   desc: -> { API::V2::Admin::Entities::Market.documentation[:max_price][:desc] }
          optional :ask_fee,
                   type: { value: BigDecimal, message: 'admin.market.non_decimal_ask_fee' },
                   values: { value: -> (p){ p >= 0 }, message: 'admin.market.invalid_ask_fee' },
                   default: 0.0,
                   desc: -> { API::V2::Admin::Entities::Market.documentation[:ask_fee][:desc] }
          optional :bid_fee,
                   type: { value: BigDecimal, message: 'admin.market.non_decimal_bid_fee' },
                   values: { value: -> (p){ p >= 0 }, message: 'admin.market.invalid_bid_fee' },
                   default: 0.0,
                   desc: -> { API::V2::Admin::Entities::Market.documentation[:bid_fee][:desc] }
          optional :min_amount,
                   type: { value: BigDecimal, message: 'admin.market.non_decimal_min_amount' },
                   values: { value: -> (p){ p >= 0 }, message: 'admin.market.invalid_min_amount' },
                   default: 0.0,
                   desc: -> { API::V2::Admin::Entities::Market.documentation[:min_amount][:desc] }
          optional :position,
                   type: { value: Integer, message: 'admin.market.non_integer_position' },
                   default: 0,
                   desc: -> { API::V2::Admin::Entities::Market.documentation[:position][:desc] }
          optional :state,
                   values: { value: ::Market::STATES, message: 'admin.market.invalid_state' },
                   default: 'enabled',
                   desc: -> { API::V2::Admin::Entities::Market.documentation[:state][:desc] }
        end

        params :update_market_params do
          requires :id,
                   type: String,
                   desc: -> { API::V2::Admin::Entities::Market.documentation[:id][:desc] }
          optional :ask_fee,
                   type: { value: BigDecimal, message: 'admin.market.non_decimal_ask_fee' },
                   values: { value: -> (p){ p >= 0 }, message: 'admin.market.invalid_ask_fee' },
                   desc: -> { API::V2::Admin::Entities::Market.documentation[:ask_fee][:desc] }
          optional :bid_fee,
                   type: { value: BigDecimal, message: 'admin.market.non_decimal_bid_fee' },
                   values: { value: -> (p){ p >= 0 }, message: 'admin.market.invalid_bid_fee' },
                   desc: -> { API::V2::Admin::Entities::Market.documentation[:bid_fee][:desc] }
          optional :min_price,
                   type: { value: BigDecimal, message: 'admin.market.non_decimal_min_price' },
                   values: { value: -> (p){ p >= 0 }, message: 'admin.market.invalid_min_price' },
                   desc: -> { API::V2::Admin::Entities::Market.documentation[:min_price][:desc] }
          optional :max_price,
                   type: { value: BigDecimal, message: 'admin.market.non_decimal_max_price' },
                   values: { value: -> (p){ p >= 0 }, message: 'admin.market.invalid_max_price' },
                   desc: -> { API::V2::Admin::Entities::Market.documentation[:max_price][:desc] }
          optional :min_amount,
                   type: { value: BigDecimal, message: 'admin.market.non_decimal_min_amount' },
                   values: { value: -> (p){ p >= 0 }, message: 'admin.market.invalid_min_amount' },
                   desc: -> { API::V2::Admin::Entities::Market.documentation[:min_amount][:desc] }
          optional :amount_precision,
                   type: { value: BigDecimal, message: 'admin.market.non_decimal_amount_precision' },
                   values: { value: -> (p){ p >= 0 }, message: 'admin.market.invalid_amount_precision' },
                   desc: -> { API::V2::Admin::Entities::Market.documentation[:amount_precision][:desc] }
          optional :price_precision,
                   type: { value: Integer, message: 'admin.currency.non_integer_price_precision' },
                   desc: -> { API::V2::Admin::Entities::Market.documentation[:price_precision][:desc] }
          optional :position,
                   type: { value: Integer, message: 'admin.market.non_integer_position' },
                   desc: -> { API::V2::Admin::Entities::Market.documentation[:position][:desc] }
          optional :state,
                   values: { value: ::Market::STATES, message: 'admin.market.invalid_state' },
                   desc: -> { API::V2::Admin::Entities::Market.documentation[:state][:desc] }
        end
      end
    end
  end
end
