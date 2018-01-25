module Private::Withdraws
  class EthereumController < ::Private::Withdraws::BaseController
    include ::Withdraws::Withdrawable
  end
end
