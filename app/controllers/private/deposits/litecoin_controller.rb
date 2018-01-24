module Private
  module Deposits
    class LitecoinController < ::Private::Deposits::BaseController
      include ::Deposits::CtrlCoinable
    end
  end
end
