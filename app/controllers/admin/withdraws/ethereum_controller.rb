module Admin
  module Withdraws
    class EthereumController < ::Admin::Withdraws::BaseController
      load_and_authorize_resource class: '::Withdraws::Ethereum'

      def index
        @one_ethereum = @ethereum.with_aasm_state(:accepted)
                               .order('id DESC')

        @all_ethereum = @ethereum.without_aasm_state(:accepted)
                               .where('created_at > ?', 1.day.ago)
                               .order('id DESC')
      end

      def show; end

      def update
        @ethereum.process!
        redirect_to :back, notice: t('.notice')
      end

      def destroy
        @ethereum.reject!
        redirect_to :back, notice: t('.notice')
      end
    end
  end
end
