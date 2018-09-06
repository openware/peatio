# encoding: UTF-8
# frozen_string_literal: true

module Admin
  class UpstreamsController < BaseController
    def index
      @upstreams = Upstream.all.page(params[:page]).per(100)
    end

    def show
      @upstream = Upstream.find(params[:id])
    end

    def new
      @upstream = Upstream.new
      render :show
    end

    def create
      @upstream = Upstream.new(upstream_params)
      if @upstream.save
        redirect_to admin_upstreams_path
      else
        flash[:alert] = @upstream.errors.full_messages
        render :show
      end
    end

    def update
      @upstream = Upstream.find(params[:id])
      if @upstream.update(upstream_params)
        redirect_to admin_upstreams_path
      else
        flash[:alert] = @upstream.errors.full_messages
        redirect_to :back
      end
    end

    private

    def upstream_params
      params.require(:upstream).permit(permitted_upstream_attributes)
    end

    def permitted_upstream_attributes
      %i[
          provider
          api_key
          api_secret
          timeout
          enabled
      ]
    end

  end
end
