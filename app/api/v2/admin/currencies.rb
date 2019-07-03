# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      class Currencies < Grape::API
        helpers ::API::V2::Admin::CurrencyParams

        desc 'Get list of currencies',
          is_array: true,
          success: API::V2::Admin::Entities::Currency
        params do
          optional :type,
                   type: String,
                   values: { value: ::Currency.types.map(&:to_s), message: 'admin.currency.invalid_type' },
                   desc: -> { API::V2::Admin::Entities::Currency.documentation[:type][:desc] }
          optional :limit,
                   type: { value: Integer, message: 'admin.currency.non_integer_limit' },
                   values: { value: 1..1000, message: 'admin.currency.invalid_limit' },
                   default: 100,
                   desc: 'Limit the number of returned currencies. Default to 100.'
          optional :page,
                   type: { value: Integer, message: 'admin.currency.non_integer_page' },
                   allow_blank: false,
                   default: 1,
                   desc: 'Specify the page of paginated results.'
          optional :ordering,
                   type: String,
                   values: { value: %w(asc desc), message: 'admin.currency.invalid_ordering' },
                   default: 'asc',
                   desc: 'If set, returned currencies will be sorted in specific order, defaults to \'asc\'.'
          optional :order_by,
                   default: 'id',
                   type: String,
                   desc: 'Name of the field, which will be ordered by.'
        end
        get '/currencies' do
          authorize! :read, Currency

          search = Currency.ransack(type_eq: params[:type])
          search.sorts = "#{params[:order_by]} #{params[:ordering]}"

          present paginate(search.result), with: API::V2::Admin::Entities::Currency
        end

        desc 'Get a currency.' do
          success API::V2::Admin::Entities::Currency
        end
        params do
          requires :id,
                   type: String,
                   values: { value: -> { Currency.codes(bothcase: true) }, message: 'admin.currency.doesnt_exist'},
                   desc: -> { API::V2::Admin::Entities::Currency.documentation[:id][:desc] }
        end
        get '/currencies/:id' do
          authorize! :read, Currency

          present Currency.find(params[:id]), with: API::V2::Admin::Entities::Currency
        end

        desc 'Create new currency.' do
          success API::V2::Admin::Entities::Currency
        end
        params do
          use :create_currency_params
        end
        post '/currencies/new' do
          authorize! :create, Currency

          currency = Currency.new(declared(params))
          if currency.save
            present currency, with: API::V2::Admin::Entities::Currency
            status 201
          else
            body errors: currency.errors.full_messages
            status 422
          end
        end

        desc 'Update currency.' do
          success API::V2::Admin::Entities::Currency
        end
        params do
          use :update_currency_params
        end
        post '/currencies/update' do
          authorize! :write, Currency

          currency = Currency.find(params[:id])
          if currency.update(declared(params, include_missing: false))
            present currency, with: API::V2::Admin::Entities::Currency
          else
            body errors: currency.errors.full_messages
            status 422
          end
        end
      end
    end
  end
end
