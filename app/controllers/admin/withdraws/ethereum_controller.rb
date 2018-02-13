module Admin
  module Withdraws
    class EthereumController < CoinsController
      load_and_authorize_resource class: '::Withdraws::Ethereum'
    end
  end
end
