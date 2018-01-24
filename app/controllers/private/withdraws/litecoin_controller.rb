module Private::Withdraws
  class LitecoinController < ::Private::Withdraws::BaseController
    include ::Withdraws::Withdrawable
  end
end
