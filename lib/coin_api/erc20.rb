# frozen_string_literal: true

module CoinAPI
  class ERC20 < ETH
    ADDRESS_REGEXP = /\A0x[a-fA-F0-9]{40}\z/
    private_constant :ADDRESS_REGEXP

    delegate :token_address, to: :currency

    def load_balance!
      data = build_data('balanceOf(address)', eth_coinbase)

      do_request(:eth_call, {to: token_address, data: data}, 'latest').yield_self do |result|
        formatter.to_float_with_precision(result)
      end
    end

    def load_deposit!(txid)
      do_request(:eth_getTransactionByHash, txid).yield_self { |tx| build_deposit(tx) }
    end

    def inspect_address!(address)
      {
        address: address,
        is_valid: ADDRESS_REGEXP.match?(address),
        is_mine: address == eth_coinbase
      }
    end

    def create_withdrawal!(_issuer, recipient, amount, fee)
      data = build_data(
        'transfer(address,uint256)',
        recipient.fetch(:address),
        formatter.to_hex(amount)
      )

      do_request(
        :eth_sendTransaction,
        from: eth_coinbase,
        to: token_address,
        data: data,
        gas: "0x#{formatter.to_hex(fee)}"
      )
    end

    def each_deposit!
      # TODO: implement (full scan blocks ?)
    end

    private

    def build_data(method, *args)
      args.each_with_object(method_identifier(method)) do |arg, data|
        data.concat(arg.gsub(/^0x/, '').rjust(64, '0'))
      end
    end

    def eth_call(*params)
      do_request(:eth_call, *params)
    end

    def method_identifier(method)
      '0x' + Digest::SHA3.hexdigest(method, 256)[0..7]
    end

    def build_deposit(tx)
      address_hex, amount_hex = formatter.from_input(tx.fetch('input'))

      {
        id: tx.fetch('hash'),
        confirmations: calculate_confirmations(formatter.to_int(tx.fetch('blockNumber'))),
        entries: [{amount: formatter.to_float_with_precision(amount_hex), address: formatter.to_address(address_hex)}]
      }
    end

    def calculate_confirmations(block_number)
      return 0 unless block_number.present?

      current_block_number = formatter.to_int(do_request(:eth_blockNumber))
      current_block_number - block_number
    end
  end
end
