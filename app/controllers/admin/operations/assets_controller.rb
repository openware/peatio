# encoding: UTF-8
# frozen_string_literal: true

require_dependency 'admin/operations/base_controller'

module Admin
  module Operations
    class AssetsController < BaseController
      def index
        @assets = ::Operations::Asset.includes(:reference, :currency)
                                     .where(currency: currency)
                                     .order(id: :desc)
                                     .page(params[:page])
                                     .per(20)
      end
    end
  end
end
