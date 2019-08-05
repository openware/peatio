# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      module Helpers
        extend ::Grape::API::Helpers

        class RansackBuilder
          # RansackBuilder creates a hash in a format ransack accepts
          # eq(:column) generetes a pair column_eq: params[:column]
          # map(:column1 => :column2) generates a pair column1_eq: params[:column2]
          # build returns prepared hash and merges additional selectors if specified

          def initialize(params)
            @params = params
            @build = {}
          end

          def build(opt = {})
            if @params[:range]
              @build.merge!("#{@params[:range]}_at_gteq" => Time.at(@params[:from])) if @params[:from]
              @build.merge!("#{@params[:range]}_at_lt" => Time.at(@params[:to])) if @params[:to]
            end
            @build.merge!(opt)
          end

          def map(opt)
            opt.each { |k, v| @build.merge!("#{k}_eq" => @params[v]) }
            self
          end

          def eq(*keys)
            keys.each { |k| @build.merge!("#{k}_eq" => @params[k]) }
            self
          end
        end

        params :currency_type do
          optional :type,
                   type: String,
                   values: { value: ::Currency.types.map(&:to_s), message: 'admin.currency.invalid_type' },
                   desc: -> { API::V2::Admin::Entities::Currency.documentation[:type][:desc] }
        end

        params :currency do
          optional :currency,
                   values: { value: -> { Currency.enabled.codes(bothcase: true) }, message: 'admin.currency.doesnt_exist' },
                   desc: -> { API::V2::Admin::Entities::Deposit.documentation[:currency][:desc] }
        end

        params :uid do
          optional :uid,
                   values:  { value: -> (v) {Member.find_by(uid: v) }, message: 'admin.user.doesnt_exist' },
                   desc: -> { API::V2::Entities::Member.documentation[:uid][:desc] }
        end

        params :pagination do
          optional :limit,
                   type: { value: Integer, message: 'admin.pagination.non_integer_limit' },
                   values: { value: 1..1000, message: 'admin.pagination.invalid_limit' },
                   default: 100,
                   desc: 'Limit the number of returned paginations. Defaults to 100.'
          optional :page,
                   type: { value: Integer, message: 'admin.pagination.non_integer_page' },
                   allow_blank: false,
                   default: 1,
                   desc: 'Specify the page of paginated results.'
        end

        params :ordering do
          optional :ordering,
                   values: { value: %w(asc desc), message: 'admin.pagination.invalid_ordering' },
                   default: 'asc',
                   desc: 'If set, returned values will be sorted in specific order, defaults to \'asc\'.'
          optional :order_by,
                   default: 'id',
                   desc: 'Name of the field, which result will be ordered by.'
        end

        params :date_picker do |options|
          optional :range,
                   default: 'created',
                   values: { value: -> { %w[created updated completed] } },
                   desc: 'Date range picker, defaults to \'created\'.'
          optional :from,
                   type: { value: Integer, message: 'admin.filter.non_integer_range_from' },
                   desc: 'An integer represents the seconds elapsed since Unix epoch.'\
                     'If set, only entities FROM the time will be retrieved.'
          optional :to,
                   type: { value: Integer, message: 'admin.filter.non_integer_range_to' },
                   desc: 'An integer represents the seconds elapsed since Unix epoch.'\
                     'If set, only entities BEFORE the time will be retrieved.'
        end
      end
    end
  end
end
