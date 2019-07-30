# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      module Helpers
        extend ::Grape::API::Helpers

        class RansackBuilder
          def initialize(params)
            @params = params
            @build = {}
          end

          def build(opt = {})
            @build.merge!(opt)
          end

          def map(opt)
            opt.each { |k, v| @build.merge!("#{k}_eq".to_sym => @params[v]) }
            self
          end

          def date(*keys)
            keys.each do |k|
              @build.merge!("#{k}_gteq".to_sym => time_param(@params["#{k}_from"]))
              @build.merge!("#{k}_lt".to_sym => time_param(@params["#{k}_to"]))
            end
            self
          end

          def eq(*keys)
            keys.each { |k| @build.merge!("#{k}_eq".to_sym => @params[k]) }
            self
          end

          def time_param(param)
            param.present? ? Time.at(param) : nil
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
          optional :ordering,
                   values: { value: %w(asc desc), message: 'admin.pagination.invalid_ordering' },
                   default: 'asc',
                   desc: 'If set, returned values will be sorted in specific order, defaults to \'asc\'.'
          optional :order_by,
                   default: 'id',
                   desc: 'Name of the field, which result will be ordered by.'
        end

        params :date_picker do |options|
          options[:keys].each do |key|
            optional "#{key}_from",
                     type: { value: Integer, message: "admin.filter.non_integer_#{key}_from" },
                     allow_blank: { value: false, message: "admin.filter.empty_#{key}_from" },
                     desc: "If set, only entities with #{key} greater or equal then will be returned."
            optional "#{key}_to",
                     type: { value: Integer, message: "admin.filter.non_integer_#{key}_to" },
                     allow_blank: { value: false, message: "admin.filter.empty_#{key}_to" },
                     desc: "If set, only withdraws with #{key} less then will be returned."
          end
        end
      end
    end
  end
end
