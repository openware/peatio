# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      class Markets < Grape::API
        helpers ::API::V2::Admin::MarketParams

        desc 'Get all markets, result is paginated.',
          is_array: true,
          success: API::V2::Admin::Entities::Market
        params do
          optional :limit,
                   type: { value: Integer, message: 'admin.market.non_integer_limit' },
                   values: { value: 1..1000, message: 'admin.market.invalid_limit' },
                   default: 100,
                   desc: 'Limit the number of returned markets. Default to 100.'
          optional :page,
                   type: { value: Integer, message: 'admin.market.non_integer_page' },
                   allow_blank: false,
                   default: 1,
                   desc: 'Specify the page of paginated results.'
          optional :ordering,
                   type: String,
                   values: { value: %w(asc desc), message: 'admin.market.invalid_ordering' },
                   default: 'asc',
                   desc: 'If set, returned markets will be sorted in specific order, default to \'asc\'.'
          optional :order_by,
                   default: 'id',
                   type: String,
                   desc: 'Name of the field, which will be ordered by.'
        end
        get '/markets' do
          authorize! :read, ::Market

          search = ::Market.ransack()
          search.sorts = "#{params[:order_by]} #{params[:ordering]}"
          present paginate(search.result), with: API::V2::Admin::Entities::Market
        end

        desc 'Get market.' do
          success API::V2::Admin::Entities::Market
        end
        params do
          requires :id,
                   type: String,
                   desc: -> { API::V2::Admin::Entities::Market.documentation[:id][:desc] }
        end
        get '/markets/:id' do
          authorize! :read, ::Market

          present ::Market.find(params[:id]), with: API::V2::Admin::Entities::Market
        end

        desc 'Create new market.' do
          success API::V2::Admin::Entities::Market
        end
        params do
          use :create_market_params
        end
        post '/markets/new' do
          authorize! :create, ::Market

          market = ::Market.new(declared(params))
          if market.save
            present market, with: API::V2::Admin::Entities::Market
            status 201
          else
            body errors: market.errors.full_messages
            status 422
          end
        end

        desc 'Update market.' do
          success API::V2::Admin::Entities::Market
        end
        params do
          use :update_market_params
        end
        post '/markets/update' do
          authorize! :write, ::Market

          market = ::Market.find(params[:id])
          if market.update(declared(params, include_missing: false))
            present market, with: API::V2::Admin::Entities::Market
          else
            body errors: market.errors.full_messages
            status 422
          end
        end
      end
    end
  end
end
