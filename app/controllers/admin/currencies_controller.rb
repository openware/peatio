module Admin
  class CurrenciesController < BaseController
    load_and_authorize_resource

    def index
      @currencies = Currency.page(params[:page])
    end

    def new
      @currency = Currency.new
      render :show
    end

    def create
      @currency = Currency.new(currency_params)
      if @currency.save
        redirect_to admin_currencies_path
      else
        flash[:alert] = @currency.errors.full_messages.first
        render :show
      end
    end

    def show
      @currency = Currency.find(params[:id])
    end

    def update
      @currency = Currency.find(params[:id])
      if @currency.update(market_params)
        redirect_to admin_currencies_path
      else
        flash[:alert] = @currency.errors.full_messages.first
        redirect_to :back
      end
    end

    private
    def currency_params
      params.require(:currency)
            .permit(:code, :etc)
    end
  end
end