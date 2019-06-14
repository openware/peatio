# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      module NamedParams
        extend ::Grape::API::Helpers

        params :orders_param do
          optional :market,
                   type: String,
                   values: { value: -> { ::Market.enabled.ids }, message: 'admin.market.doesnt_exist' },
                   desc: -> { V2::Entities::Market.documentation[:id] }
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
                   desc: -> { V2::Admin::Entities::Order.documentation[:price] }
          optional :origin_volume,
                   type: { value: BigDecimal, message: 'admin.order.non_decimal_price' },
                   values: { value: -> (p){ p.try(:positive?) }, message: 'admin.order.non_positive_origin_volume' },
                   desc: -> { V2::Admin::Entities::Order.documentation[:origin_volume] }
          optional :type,
                   type: String,
                   values: { value: %w(buy sell), message: 'admin.order.invalid_type' },
                   desc: 'Filter order by type.'
          optional :email,
                   type: { value: String, message: 'admin.email.non_string_email'},
                   desc: -> { V2::Entities::Member.documentation[:email] }
          optional :uid,
                   type: { value: String, message: 'admin.uid.non_string_uid'},
                   desc: -> { V2::Entities::Member.documentation[:uid] }
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

        params :blockchains_param do
          requires :key,
                   type: { value: String, message: 'admin.key.non_string_key'},
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:key] }
          requires :name,
                   type: { value: String, message: 'admin.name.non_string_name'},
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:name] }
          requires :client,
                   type: { value: String, message: 'admin.client.non_string_client'},
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:client] }
          requires :server,
                   type: { value: String, message: 'admin.server.non_string_server'},
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:server] }
          requires :height,
                   type: { value: Integer, message: 'admin.height.non_integer_height' },
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:height] }
          requires :explorer_transaction,
                   type: { value: String, message: 'admin.explorer_transaction.non_string_explorer_transaction'},
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:explorer_transaction] }
          requires :explorer_address,
                   type: { value: String, message: 'admin.explorer_address.non_string_explorer_address'},
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:explorer_address] }
          requires :status,
                   type: String,
                   values: { value: %w(active disabled), message: 'admin.status.invalid_status' },
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:status] }
          requires :min_confirmations,
                   type: { value: Integer, message: 'admin.min_confirmations.non_integer_min_confirmations' },
                   values: { value: -> (p){ p > 0 }, message: 'admin.min_confirmations.non_positive_min_confirmations' },
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:min_confirmations] }
          requires :step,
                   type: { value: Integer, message: 'admin.step.non_integer_step' },
                   values: { value: -> (p){ p > 0 }, message: 'admin.step.non_positive_step' },
                   desc: -> { V2::Admin::Entities::Blockchain.documentation[:step] }
        end

        params :paginate_param do
          optional :limit,
                   type: { value: Integer, message: 'admin.order.non_integer_limit' },
                   values: { value: 1..1000, message: 'admin.order.invalid_limit' },
                   default: 100,
                   desc: 'Limit the number of returned orders. Default to 100.'
          optional :page,
                   type: { value: Integer, message: 'admin.order.non_integer_page' },
                   allow_blank: false,
                   default: 1,
                   desc: 'Specify the page of paginated results.'
        end
      end
    end
  end
end
