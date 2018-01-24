module Admin
  module Deposits
    class LitecoinController < ::Admin::Deposits::BaseController
      load_and_authorize_resource class: '::Deposits::Litecoin'

      def index
      end

      def update
        @litecoin.accept! if @litecoin.may_accept?
        redirect_to :back, notice: t('.notice')
      end
    end
  end
end
