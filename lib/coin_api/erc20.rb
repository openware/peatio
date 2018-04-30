module CoinAPI
    class ERC20 < ETH

      def load_balance!
        PaymentAddress
            .where(currency: currency)
            .where(PaymentAddress.arel_table[:address].is_not_blank)
            .pluck(:address)
            .reject(&:blank?)
            .map do |address|
          data = build_data('balanceOf(address)', address)
          json_rpc(:eth_call, [{to: currency.erc20_contract_address, data: "0x" + data}, 'latest']).fetch('result').hex.to_d
        rescue => e
          report_exception_to_screen(e)
          0.0
        end.reduce(&:+).yield_self { |total| total ? convert_from_base_unit(total) : 0.to_d }
      end

      def create_withdrawal!(issuer, recipient, amount, options = {})
        permit_transaction(issuer, recipient)
        data = build_data(
            'transfer(address,uint256)', recipient.fetch(:address), '0x' + convert_to_base_unit!(amount).to_s(16)
        )

        json_rpc(
            :eth_sendTransaction,
            [{
                 from:  issuer.fetch(:address),
                 to: currency.erc20_contract_address,
                 data: "0x" + data,
                 gas:   nil
             }.compact]
        ).fetch('result').yield_self do |txid|
          if txid.to_s.match?(/\A0x[A-F0-9]{64}\z/i)
            txid
          else
            raise CoinAPI::Error, "ERC20 withdrawal from #{issuer.fetch(:address)} to #{recipient.fetch(:address)} failed."
          end
        end
      end

      def load_deposit!(txid)
        json_rpc(:eth_getTransactionReceipt, [txid]).fetch('result').yield_self do |tx|

          return {} unless tx['status'] == '0x1'
          entries = tx['logs'].each_with_object([]) do |log, result|
            next unless log['address'].try(:downcase) == currency.erc20_contract_address.try(:downcase)
            result << {
                amount: log['data'].hex.to_f / 10**currency.precision,
                address: "0x" + log['topics'].last[-40..-1]
            }
          end

          {
              id: tx.fetch('transactionHash'),
              confirmations: latest_block_number - tx.fetch('blockNumber').hex,
              entries: entries
          }
        end
      end

      private

      def build_data(method, *args)
          args.each_with_object(Digest::SHA3.hexdigest(method, 256)[0..7].dup) do |arg, data|
              data.concat(arg.gsub(/^0x/, '').rjust(64, '0'))
          end
      end

      protected

      def build_deposit_collection(txs, current_block, latest_block)
        txs.map do |tx|
         if tx.fetch('input').hex > 0 and tx.fetch('to').try(:downcase) == currency.erc20_contract_address.try(:downcase)
           input_data = tx.fetch('input').bytes.map(&:chr).drop(10).join
           { id:            tx.fetch('hash'),
             confirmations: latest_block.fetch('number').hex - current_block.fetch('number').hex,
             received_at:   Time.at(current_block.fetch('timestamp').hex),
             entries:       [{ amount:  convert_from_base_unit(input_data[(input_data.length/2..input_data.length)].hex),
                               address: "0x" + input_data[0..input_data.length/2-1][-40..-1] }] }
         end
        end.compact
      end

      end
  end
