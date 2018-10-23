# encoding: UTF-8
# frozen_string_literal: true

module WalletClient
  class Wcg < Nxt

    def initialize(*)
      super
      @json_rpc_endpoint = URI.parse(wallet.uri + "/wcg?")
    end

  end
end
