module Admin
  module Withdraws
    class LitecoinController < ::Admin::Withdraws::BaseController
      load_and_authorize_resource class: '::Withdraws::Litecoin'

      def index
        @litecoin = @litecoin.includes(:member).
                      where('created_at > ?', start_at).
                      order('id DESC').
                      page(params[:page]).
                      per(20)
      end

      def show
      end

      def update
        @litecoin.process!
        redirect_to :back, notice: t('.notice')
      end

      def destroy
        @litecoin.reject!
        redirect_to :back, notice: t('.notice')
      end
    end
  end
end
