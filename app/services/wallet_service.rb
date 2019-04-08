# encoding: UTF-8
# frozen_string_literal: true

class WalletService

  class << self
    #
    # Returns WalletService for given wallet.
    #
    # @param wallet [String, Symbol]
    #   The wallet record in database.
    def [](wallet)
      @adapter = Peatio::WalletService
        .adapter_for(wallet.gateway.to_sym)
        .new(wallet: wallet)
    end
  end
end
