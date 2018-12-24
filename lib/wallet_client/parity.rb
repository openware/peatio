# encoding: UTF-8
# frozen_string_literal: true

module WalletClient
  class Parity < Ethereum
    def create_eth_withdrawal!(issuer, recipient, amount, options = {})
      json_rpc(
          :personal_sendTransaction,
          [{
               from:     normalize_address(issuer.fetch(:address)),
               to:       normalize_address(recipient.fetch(:address)),
               gas:      options.key?(:gas_limit) ? '0x' + options[:gas_limit].to_s(16) : nil,
               gasPrice: options.key?(:gas_price) ? '0x' + options[:gas_price].to_s(16) : nil,
               value:    '0x' + amount.to_s(16)
          }.compact, issuer.fetch(:secret)]
      ).fetch('result').yield_self do |txid|
        raise WalletClient::Error, \
          "#{wallet.name} withdrawal from #{normalize_address(issuer[:address])} to #{normalize_address(recipient[:address])} failed." \
            unless valid_txid?(normalize_txid(txid))
        normalize_txid(txid)
      end
    end

    def create_erc20_withdrawal!(issuer, recipient, amount, options = {})
      data = abi_encode \
        'transfer(address,uint256)',
        normalize_address(recipient.fetch(:address)),
        '0x' + amount.to_s(16)

      json_rpc(
          :personal_sendTransaction,
          [{
               from: normalize_address(issuer.fetch(:address)),
               to:   options[:contract_address],
               data: data
           }, issuer.fetch(:secret)]
      ).fetch('result').yield_self do |txid|
        raise WalletClient::Error, \
          "#{wallet.name} withdrawal from #{normalize_address(issuer[:address])} to #{normalize_address(recipient[:address])} failed." \
            unless valid_txid?(normalize_txid(txid))
        normalize_txid(txid)
      end
    end
  end
end
