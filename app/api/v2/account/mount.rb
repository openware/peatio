module API::V2
  module Account
    class Mount < Grape::API
      include NewExceptionsHandlers

      before { authenticate! }

      mount Account::Withdraws
      mount Account::Deposits
      mount Account::Balances
    end
  end
end
