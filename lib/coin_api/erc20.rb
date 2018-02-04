# frozen_string_literal: true

module CoinAPI
  class ERC20 < ETH
    delegate :token_address, to: :currency

    def load_balance!
      method = "balanceOf(address)"
      data = method_identifier("balanceOf(address)").ljust(34, '0').concat(hot_wallet_address.gsub(/^0x/,''))
      result = do_request(:eth_call, {to: token_address, data: data}, 'latest')
      result.hex.to_f / 10 ** precision
    end

    private

    def eth_call(*params)
      do_request(:eth_call, *params)
    end

    def method_identifier(method)
      method_hex = "0x" + method.each_byte.map { |b| b.to_s(16) }.join
      do_request(:web3_sha3, method_hex)[0..9]
    end
  end
end
