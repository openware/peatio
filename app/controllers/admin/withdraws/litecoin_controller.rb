module Admin
  module Withdraws
    class LitecoinController < ::Admin::Withdraws::BaseController
      load_and_authorize_resource class: '::Withdraws::Litecoin'

      def index
      end

      def show
      end

      def update
      end

      def destroy
        @litecoin.reject!
        redirect_to :back, notice: t('.notice')
      end
    end
  end
end
