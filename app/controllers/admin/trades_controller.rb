# encoding: UTF-8
# frozen_string_literal: true

module Admin
  class TradesController < BaseController
    load_and_authorize_resource

    def index
      @trades = Trade.all.page(params[:page]).per(params[20])
    end
  end
end
