module Private
  module Deposits
    class EthereumController < ::Private::Deposits::BaseController
      include ::Deposits::CtrlCoinable
    end
  end
end
