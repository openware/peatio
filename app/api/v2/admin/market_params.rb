#encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      module MarketParams
        extend ::Grape::API::Helpers

        params :create_market_params do
          requires :ask_unit,
                   type: String,
                   values: { value: -> { ::Currency.ids }, message: 'admin.market.currency_doesnt_exist' },
                   desc: -> { V2::Admin::Entities::Market.documentation[:ask_unit][:desc] }
          requires :bid_unit,
                   type: String,
                   values: { value: -> { ::Currency.ids }, message: 'admin.market.currency_doesnt_exist' },
                   desc: -> { V2::Admin::Entities::Market.documentation[:bid_unit][:desc] }
          optional :ask_fee,
                   type: { value: BigDecimal, message: 'admin.market.non_decimal_ask_fee' },
                   values: { value: -> (p){ p >= 0 }, message: 'admin.market.invalid_ask_fee' },
                   default: 0.0,
                   desc: -> { V2::Admin::Entities::Market.documentation[:ask_fee][:desc] }
          optional :bid_fee,
                   type: { value: BigDecimal, message: 'admin.market.non_decimal_bid_fee' },
                   values: { value: -> (p){ p >= 0 }, message: 'admin.market.invalid_bid_fee' },
                   default: 0.0,
                   desc: -> { V2::Admin::Entities::Market.documentation[:bid_fee][:desc] }
          optional :min_ask_price,
                   type: { value: BigDecimal, message: 'admin.market.non_decimal_min_ask_price' },
                   values: { value: -> (p){ p >= 0 }, message: 'admin.market.invalid_min_ask_price' },
                   default: 0.0,
                   desc: -> { V2::Admin::Entities::Market.documentation[:min_ask_price][:desc] }
          optional :max_bid_price,
                   type: { value: BigDecimal, message: 'admin.market.non_decimal_max_bid_price' },
                   values: { value: -> (p){ p >= 0 }, message: 'admin.market.invalid_max_bid_price' },
                   default: 0.0,
                   desc: -> { V2::Admin::Entities::Market.documentation[:max_bid_price][:desc] }
          optional :min_ask_amount,
                   type: { value: BigDecimal, message: 'admin.market.non_decimal_min_ask_amount' },
                   values: { value: -> (p){ p >= 0 }, message: 'admin.market.invalid_min_ask_amount' },
                   default: 0.0,
                   desc: -> { V2::Admin::Entities::Market.documentation[:min_ask_amount][:desc] }
          optional :min_bid_amount,
                   type: { value: BigDecimal, message: 'admin.market.non_decimal_min_bid_amount' },
                   values: { value: -> (p){ p >= 0 }, message: 'admin.market.invalid_min_bid_amount' },
                   default: 0.0,
                   desc: -> { V2::Admin::Entities::Market.documentation[:min_bid_amount][:desc] }
          optional :position,
                   type: { value: Integer, message: 'admin.market.non_integer_position' },
                   default: 0,
                   desc: -> { V2::Admin::Entities::Market.documentation[:position][:desc] }
          optional :enabled,
                   type: { value: Boolean, message: 'admin.market.non_boolean_enabled' },
                   default: true,
                   desc: -> { V2::Admin::Entities::Market.documentation[:enabled][:desc] }
        end

        params :update_market_params do
          requires :id,
                   type: String,
                   desc: -> { API::V2::Admin::Entities::Market.documentation[:id][:desc] }
          optional :ask_fee,
                   type: { value: BigDecimal, message: 'admin.market.non_decimal_ask_fee' },
                   values: { value: -> (p){ p >= 0 }, message: 'admin.market.invalid_ask_fee' },
                   desc: -> { V2::Admin::Entities::Market.documentation[:ask_fee][:desc] }
          optional :bid_fee,
                   type: { value: BigDecimal, message: 'admin.market.non_decimal_bid_fee' },
                   values: { value: -> (p){ p >= 0 }, message: 'admin.market.invalid_bid_fee' },
                   desc: -> { V2::Admin::Entities::Market.documentation[:bid_fee][:desc] }
          optional :min_ask_price,
                   type: { value: BigDecimal, message: 'admin.market.non_decimal_min_ask_price' },
                   values: { value: -> (p){ p >= 0 }, message: 'admin.market.invalid_min_ask_price' },
                   desc: -> { V2::Admin::Entities::Market.documentation[:min_ask_price][:desc] }
          optional :max_bid_price,
                   type: { value: BigDecimal, message: 'admin.market.non_decimal_max_bid_price' },
                   values: { value: -> (p){ p >= 0 }, message: 'admin.market.invalid_max_bid_price' },
                   desc: -> { V2::Admin::Entities::Market.documentation[:max_bid_price][:desc] }
          optional :min_ask_amount,
                   type: { value: BigDecimal, message: 'admin.market.non_decimal_min_ask_amount' },
                   values: { value: -> (p){ p >= 0 }, message: 'admin.market.invalid_min_ask_amount' },
                   desc: -> { V2::Admin::Entities::Market.documentation[:min_ask_amount][:desc] }
          optional :min_bid_amount,
                   type: { value: BigDecimal, message: 'admin.market.non_decimal_min_bid_amount' },
                   values: { value: -> (p){ p >= 0 }, message: 'admin.market.invalid_min_bid_amount' },
                   desc: -> { V2::Admin::Entities::Market.documentation[:min_bid_amount][:desc] }
          optional :ask_precision,
                   type: { value: Integer, message: 'admin.currency.non_integer_ask_precision' },
                   desc: -> { V2::Admin::Entities::Market.documentation[:ask_precision][:desc] }
          optional :bid_precision,
                   type: { value: Integer, message: 'admin.currency.non_integer_bid_precision' },
                   desc: -> { V2::Admin::Entities::Market.documentation[:bid_precision][:desc] }
          optional :position,
                   type: { value: Integer, message: 'admin.market.non_integer_position' },
                   desc: -> { V2::Admin::Entities::Market.documentation[:position][:desc] }
          optional :enabled,
                   type: { value: Boolean, message: 'admin.market.non_boolean_enabled' },
                   desc: -> { V2::Admin::Entities::Market.documentation[:enabled][:desc] }
        end
      end
    end
  end
end
