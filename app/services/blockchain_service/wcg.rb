# encoding: UTF-8
# frozen_string_literal: true

module BlockchainService
  class Wcg < Nxt

    private

    def currency
      @currency ||= Currency.find(:wcg)
    end
  end
end

