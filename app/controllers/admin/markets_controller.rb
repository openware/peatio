module Admin
  class MarketsController < BaseController
    load_and_authorize_resource

    def index
      @markets = Market.all.page params[:page]
    end
  end
end
