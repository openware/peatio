module Admin
  class MarketsController < BaseController
    load_and_authorize_resource

    def index
      @markets = Market.all.page params[:page]
    end

    def new
      @deposit = Market.new
    end

    def create
      market_params
      binding.pry
    end

    private
    def market_params
      params.require(:market).permit(:bid_unit)
    end
    # def show
    #   @market = Market.find_by_id(params[:id])
    # end
  end
end
