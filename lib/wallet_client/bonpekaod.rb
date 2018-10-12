# encoding: UTF-8
# frozen_string_literal: true

module WalletClient
  class Bonpekaod < Bitcoind

    def create_withdrawal!(issuer, recipient, amount, options = {})
      options.merge!(subtract_fee: false) unless options.has_key?(:subtract_fee)

      json_rpc(:settxfee, [options[:fee]]) if options.key?(:fee)
      json_rpc(:sendtoaddress, [normalize_address(recipient.fetch(:address)), amount.to_f])
          .fetch('result')
          .yield_self(&method(:normalize_txid))
    end

  end
end
