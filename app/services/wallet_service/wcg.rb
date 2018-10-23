# encoding: UTF-8
# frozen_string_literal: true

module WalletService
  class Wcg < Nxt

    private

    def default_fee
      0.01
    end

    def txn_fees_wallet
      Wallet
          .active
          .withdraw
          .find_by(currency_id: :wcg, kind: :hot)
    end
  end
end
