module Private::Withdraws
  class RipplesController < ::Private::Withdraws::BaseController
    include ::Withdraws::Withdrawable

    def new
      @withdraw = Withdraw.new
    end

  end
end
