# encoding: UTF-8
# frozen_string_literal: true

module Admin
  class BlockchainsController < BaseController
    def index
      @blockchains = Blockchain.all
    end

    def new
      @blockchain = Blockchain.new
      render :show
    end

    def create
      @blockchain = Blockchain.new
      @blockchain.assign_attributes(blockchain_params)
      if @blockchain.save
        redirect_to admin_blockchains_path
      else
        flash[:alert] = @blockchain.errors.full_messages.first
        render :show
      end
    end

    def show
      @blockchain = Blockchain.find(params[:id])
    end

    def update
      @blockchain = Blockchain.find(params[:id])
      if @blockchain.update(blockchain_params)
        redirect_to admin_blockchains_path
      else
        flash[:alert] = @blockchain.errors.full_messages.first
        redirect_to :back
      end
    end

    private

    def blockchain_params
      params.require(:blockchain).permit(permitted_blockchain_attributes)
    end

    def permitted_blockchain_attributes
      %i[
          key
          name
          client
          server
          height
          explorer_address
          explorer_transaction
          status
      ]

    end

  end
end
