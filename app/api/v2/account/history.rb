# encoding: UTF-8
# frozen_string_literal: true

require_relative '../validations'

module API
  module V2
    module Account
      class History < Grape::API

        before { deposits_must_be_permitted! }
        before { withdraws_must_be_permitted! }

        desc 'Get your transactions and trades history.',
          is_array: true,
          success: API::V2::Entities::LiabilityHistory

        params do
          optional :currency,
                   type: String,
                   values: { value: -> { Currency.enabled.codes(bothcase: true) }, message: 'account.currency.doesnt_exist' },
                   desc: 'Currency code'

          optional :filter,
                   type: String,
                   values: { value: %w(trade deposit+withdraw trade+deposit+withdraw), message: 'account.history.filter_invalid'},
                   default: 'trade+deposit+withdraw',
                   desc: 'Param for filtering'

          optional :sort,
                   type: String,
                   values: { value: %w(operation_date), message: 'account.history.sort_invalid' },
                   default: 'operation_date',
                   desc: 'Param for sorting'

          optional :order_by,
                   type: String,
                   values: { value: %w(asc desc), message: 'account.history.order_by_invalid' },
                   default: 'desc',
                   desc: 'Sorting order'

          optional :time_from,
                   type: { value: Integer, message: 'account.history.non_integer_time_from' },
                   desc: 'An integer represents the seconds elapsed since Unix epoch.'

          optional :time_to,
                   type: { value: Integer, message: 'account.history.non_integer_time_to' },
                   desc: 'An integer represents the seconds elapsed since Unix epoch.'

          optional :limit,
                   type: { value: Integer, message: 'account.history.non_integer_limit' },
                   values: { value: 1..100, message: 'account.history.invalid_limit' },
                   desc: "Number of operations per page (maximum is 100)."

          optional :page,
                   type: { value: Integer, message: 'account.history.non_integer_page' },
                   values: { value: -> (p){ p.try(:positive?) }, message: 'account.history.non_positive_page'},
                   default: 1,
                   desc: 'Page number (defaults to 1).'

        end
        get "/history" do
          reference_types = params[:filter].split('+')

          history = LiabilityHistory.where(member_id: current_user.id, operation_type: reference_types)
            .tap { |q| q.where!(currency_id: params[:currency]) if params[:currency] }
            .tap { |q| q.where!('operation_date > ?', Time.at(params[:time_from])) if params[:time_from] }
            .tap { |q| q.where!('operation_date < ?', Time.at(params[:time_to])) if params[:time_to] }
            .order("#{params[:sort]} #{params[:order_by]}")

          history = paginate(history) if params[:limit]

          present history, with: API::V2::Entities::LiabilityHistory
        end

      end
    end
  end
end
