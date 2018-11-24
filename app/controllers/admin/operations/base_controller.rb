# encoding: UTF-8
# frozen_string_literal: true

require_dependency 'admin/base_controller'

module Admin
  module Operations
    class BaseController < BaseController

    protected

      def currency
        params[:currency] ? Currency.find(params[:currency]) : nil
      end
      helper_method :currency
    end
  end
end
