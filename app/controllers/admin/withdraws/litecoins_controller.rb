module Admin
  module Withdraws
    class LitecoinsController < ::Admin::Withdraws::BaseController
      load_and_authorize_resource class: '::Withdraws::Litecoin'

      def index
        @one_litecoins = @litecoins.with_aasm_state(:accepted).
                           order('id DESC')

        @all_litecoins = @litecoins.without_aasm_state(:accepted).
                           where('created_at > ?', DateTime.now.ago(60 * 60 * 24)).
                           order('id DESC')
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
