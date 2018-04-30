module CoinAPI
  class ERC20 < ETH

    def contract_address
      currency.erc20_contract_address
    end

    def create_withdrawal!(issuer, recipient, amount, options = {})
      permit_transaction(issuer, recipient)
      data = abi_encode(
        'transfer(address,uint256)', recipient.fetch(:address), '0x' + convert_to_base_unit!(amount).to_s(16)
      )

      json_rpc(
        :eth_sendTransaction,
        [{
           from: issuer.fetch(:address),
           to:   contract_address,
           data: "0x" + data,
           gas:  nil
         }.compact]
      ).fetch('result').yield_self do |txid|
        if valid_txid?(txid)
          txid
        else
          raise CoinAPI::Error, "ERC20 withdrawal from #{issuer.fetch(:address)} to #{recipient.fetch(:address)} failed."
        end
      end
    end

    def load_deposit!(txid)
      json_rpc(:eth_getTransactionReceipt, [txid]).fetch('result').yield_self do |receipt|
        break unless receipt['status'] == '0x1'

        entries = receipt.fetch('logs').map do |log|
          next unless log.fetch('address') == contract_address
          { amount:  convert_from_base_unit(log.fetch('data').hex),
            address: '0x' + log.fetch('topics').last[-40..-1] }
        end

        { id:            receipt.fetch('transactionHash'),
          confirmations: latest_block_number - receipt.fetch('blockNumber').hex,
          entries:       entries.compact }
      end
    end

  protected

    def build_deposit_collection(txs, current_block, latest_block)
      txs.map do |tx|
        if tx.fetch('input').hex > 0 and tx.fetch('to').try(:downcase) == contract_address.try(:downcase)
          input_data = tx.fetch('input').bytes.map(&:chr).drop(10).join
          { id:            tx.fetch('hash'),
            confirmations: latest_block.fetch('number').hex - current_block.fetch('number').hex,
            received_at:   Time.at(current_block.fetch('timestamp').hex),
            entries:       [{ amount:  convert_from_base_unit(input_data[(input_data.length / 2..input_data.length)].hex),
                              address: "0x" + input_data[0..input_data.length / 2 - 1][-40..-1] }] }
        end
      end.compact
    end

    def load_balance_of_address(address)
      data = abi_encode('balanceOf(address)', address)
      json_rpc(:eth_call, [{ to: contract_address, data: "0x" + data }, 'latest']).fetch('result').hex.to_d
    rescue => e
      report_exception_to_screen(e)
      0.0
    end
  end
end
