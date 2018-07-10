# encoding: UTF-8
# frozen_string_literal: true

module Admin
  class WalletsController < BaseController
    def index
      @wallets = Wallet.all.page(params[:page]).per(100)
    end

    def show
      @wallet = Wallet.find(params[:id])
    end

    def new
      @wallet = Wallet.new
      render :show
    end

    def create
      @wallet = Wallet.new(wallet_params)
      if @wallet.save
        redirect_to admin_wallets_path
      else
        flash[:alert] = @wallet.errors.full_messages
        render :show
      end
    end

    def update
      @wallet = Wallet.find(params[:id])
      if @wallet.update(wallet_params)
        redirect_to admin_wallets_path
      else
        flash[:alert] = @wallet.errors.full_messages
        redirect_to :back
      end
    end

    private

    def wallet_params
      params.require(:wallet).permit(permitted_wallet_attributes)
    end

    def permitted_wallet_attributes
      %i[
          currency_id
          name
          address
          kind
          nsig
          status
      ]
    end

  end
end
