# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      module TradeParams
        extend ::Grape::API::Helpers

        params :trade_params do
          optional :market,
                   type: String,
                   values: { value: -> { ::Market.enabled.ids }, message: 'admin.market.doesnt_exist' },
                   desc: -> { API::V2::Admin::Entities::Market.documentation[:id][:desc] }
          optional :price_from,
                   type: { value: BigDecimal, message: 'admin.trade.non_decimal_price' },
                   values: { value: -> (p){ p.try(:positive?) }, message: 'admin.trade.non_positive_price' },
                   desc: -> { API::V2::Admin::Entities::Trade.documentation[:price][:desc] }
          optional :price_to,
                   type: { value: BigDecimal, message: 'admin.trade.non_decimal_price' },
                   values: { value: -> (p){ p.try(:positive?) }, message: 'admin.trade.non_positive_price' },
                   desc: -> { API::V2::Admin::Entities::Trade.documentation[:price][:desc] }
          optional :volume_from,
                   type: { value: BigDecimal, message: 'admin.trade.non_decimal_volume' },
                   values: { value: -> (p){ p.try(:positive?) }, message: 'admin.trade.non_positive_volume' },
                   desc: -> { API::V2::Admin::Entities::Trade.documentation[:volume][:desc] }
          optional :volume_to,
                   type: { value: BigDecimal, message: 'admin.trade.non_decimal_volume' },
                   values: { value: -> (p){ p.try(:positive?) }, message: 'admin.trade.non_positive_volume' },
                   desc: -> { API::V2::Admin::Entities::Trade.documentation[:volume][:desc] }
          optional :uid,
                   type: String,
                   values:  { value: -> (v) {Member.find_by(uid: v) }, message: 'admin.user.doesnt_exist' },
                   desc: -> { API::V2::Entities::Member.documentation[:uid][:desc] }
          optional :order_id,
                   type: Integer,
                   desc: -> { API::V2::Entities::Order.documentation[:id][:desc] }
          optional :created_at_from,
                   type: { value: Integer, message: 'admin.trade.non_integer_created_at_from' },
                   allow_blank: { value: false, message: 'admin.trade.empty_time_from' },
                   desc: "An integer represents the seconds elapsed since Unix epoch."\
                         "If set, only trades executed after the time will be returned."
          optional :created_at_to,
                   type: { value: Integer, message: 'admin.trade.non_integer_created_at_to' },
                   allow_blank: { value: false, message: 'admin.trade.empty_time_to' },
                   desc: "An integer represents the seconds elapsed since Unix epoch."\
                         "If set, only trades executed before the time will be returned."
          optional :limit,
                   type: { value: Integer, message: 'admin.trade.non_integer_limit' },
                   values: { value: 1..1000, message: 'admin.trade.invalid_limit' },
                   default: 100,
                   desc: 'Limit the number of returned trades. Default to 100.'
          optional :page,
                   type: { value: Integer, message: 'admin.trade.non_integer_page' },
                   allow_blank: false,
                   default: 1,
                   desc: 'Specify the page of paginated results.'
          optional :ordering,
                   type: String,
                   values: { value: %w(asc desc), message: 'admin.trade.invalid_ordering' },
                   default: 'asc',
                   desc: 'If set, returned trades will be sorted in specific order, default to \'asc\'.'
          optional :order_by,
                   type: String,
                   default: 'id',
                   desc: 'Name of the field, which will be ordered by'
        end
      end
    end
  end
end
