module Private::Withdraws
  class SatoshisController < ::Private::Withdraws::BaseController
    include ::Withdraws::Withdrawable

    def new
      @withdraw = Withdraw.new
    end

  end
end
