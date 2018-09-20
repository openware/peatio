# encoding: UTF-8
# frozen_string_literal: true

module Admin
  class MembersController < BaseController
    load_and_authorize_resource

    def index
      @q = Member.ransack(params[:q])
      @search_field = params[:search_field]
      @search_term  = params[:search_term]
      @members      = @q.result(distinct: true).search(field: @search_field, term: @search_term).page(params[:page])
    end

    def show

    end

    def toggle
      @member.toggle!(params[:api] ? :api_disabled : :disabled)
    end
  end
end
