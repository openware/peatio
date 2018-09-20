# encoding: UTF-8
# frozen_string_literal: true

module Admin
  class OrdersController < BaseController
    load_and_authorize_resource

    def index
      @q = Order.ransack(params[:q])
      @orders = @q.result(distinct: true).page(params[:page]).per(20)
    end
  end
end
