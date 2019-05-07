# encoding: UTF-8
# frozen_string_literal: true

module WalletClient
  class Litecoind < Bitcoind

    def inspect_address!(address)
      json_rpc(:validateaddress, [normalize_address(address)]).fetch('result').yield_self do |x|
        if normalize_address(address).start_with?('L','M')
           { address: normalize_address(address), is_valid: !!x['isvalid'] }
        else
          { address: normalize_address(address), is_valid: false }
        end
      end
    end

    
  end
end
