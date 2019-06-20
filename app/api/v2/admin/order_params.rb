# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      module OrderParams
        extend ::Grape::API::Helpers

        params :order_params do
          optional :market,
                   type: String,
                   values: { value: -> { ::Market.enabled.ids }, message: 'admin.market.doesnt_exist' },
                   desc: -> { V2::Entities::Market.documentation[:id][:desc] }
          optional :state,
                   type: String,
                   values: { value: -> { Order.state.values }, message: 'admin.order.invalid_state' },
                   desc: 'Filter order by state.'
          optional :ord_type,
                   type: String,
                   values: { value: Order::TYPES, message: 'admin.order.invalid_ord_type' },
                   desc: 'Filter order by ord_type.'
          optional :price,
                   type: { value: BigDecimal, message: 'admin.order.non_decimal_price' },
                   values: { value: -> (p){ p.try(:positive?) }, message: 'admin.order.non_positive_price' },
                   desc: -> { V2::Admin::Entities::Order.documentation[:price][:desc] }
          optional :origin_volume,
                   type: { value: BigDecimal, message: 'admin.order.non_decimal_price' },
                   values: { value: -> (p){ p.try(:positive?) }, message: 'admin.order.non_positive_origin_volume' },
                   desc: -> { V2::Admin::Entities::Order.documentation[:origin_volume][:desc] }
          optional :type,
                   type: String,
                   values: { value: %w(buy sell), message: 'admin.order.invalid_type' },
                   desc: 'Filter order by type.'
          optional :email,
                   type: String,
                   desc: -> { V2::Entities::Member.documentation[:email][:desc] }
          optional :uid,
                   type: String,
                   desc: -> { V2::Entities::Member.documentation[:uid][:desc] }
          optional :updated_at_from,
                   type: { value: Integer, message: 'admin.order.non_integer_updated_at_from' },
                   allow_blank: { value: false, message: 'admin.order.empty_time_from' },
                   desc: "An integer represents the seconds elapsed since Unix epoch."\
                         "If set, only orders executed after the time will be returned."
          optional :updated_at_to,
                   type: { value: Integer, message: 'admin.order.non_integer_updated_at_to' },
                   allow_blank: { value: false, message: 'admin.order.empty_time_to' },
                   desc: "An integer represents the seconds elapsed since Unix epoch."\
                         "If set, only orders executed before the time will be returned."
          optional :created_at_from,
                   type: { value: Integer, message: 'admin.order.non_integer_updated_at_from' },
                   allow_blank: { value: false, message: 'admin.order.empty_time_from' },
                   desc: "An integer represents the seconds elapsed since Unix epoch."\
                         "If set, only orders executed after the time will be returned."
          optional :created_at_to,
                   type: { value: Integer, message: 'admin.order.non_integer_created_at_to' },
                   allow_blank: { value: false, message: 'admin.order.empty_time_to' },
                   desc: "An integer represents the seconds elapsed since Unix epoch."\
                         "If set, only orders executed before the time will be returned."
        end
      end
    end
  end
end
