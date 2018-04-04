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
      @market = Market.new(market_params)
      binding.pry
      if @market.save
        redirect_to admin_markets_path
      else
        flash[:alert] = @market.errors.full_messages.first
        render :new
      end
    end

    private
    def market_id
      raw_params[:bid_unit] + raw_params[:ask_unit]
    end

    def market_params
      raw_params.slice(:bid_unit, :bid_fee, :bid_precision, :ask_unit, :ask_fee, :ask_precision, :visible, :position)
          .merge(id: market_id)
          .permit!
    end

    def raw_params
      params.require(:market)
    end
  end
end
