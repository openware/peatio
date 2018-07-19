# encoding: UTF-8
# frozen_string_literal: true

describe BlockchainService::Bitcoin do

  around do |example|
    WebMock.disable_net_connect!
    example.run
    WebMock.allow_net_connect!
  end

  describe 'Client::Bitcoin' do
    let(:block_data) do
      Rails.root.join('spec', 'resources', 'bitcoin-data', block_file_name)
        .yield_self { |file_path| File.open(file_path) }
        .yield_self { |file| JSON.load(file) }
    end

    let(:start_block)   { block_data.first['result']['height'] }
    let(:latest_block)  { block_data.last['result']['height'] }

    let(:blockchain) do
      Blockchain.find_by_key('btc-testnet')
        .tap { |b| b.update(height: start_block) }
    end

    let(:client) { Client[blockchain.key] }

    def request_body(block_hash)
      { jsonrpc: '1.0',
        method:  :getblock,
        params:  [block_hash, 2]
      }.to_json
    end

    context 'two BTC deposit was created during blockchain proccessing' do
      # File with real json rpc data for two blocks.
      let(:block_file_name) { '1354419-1354420.json' }

      let(:expected_deposits) do
        [
          {
            amount:   1.30000000,
            address:  '2MvCSzoFbQsVCTjN2rKWPuHa3THXSp1mHWt',
            txid:     '68ecb040b8d9716c1c09d552e158f69ba9b4b2bbbfb8407bef348f78e1eabbe8'
          },
          {
              amount:   0.65000000,
              address:  '2MvCSzoFbQsVCTjN2rKWPuHa3THXSp1mHWt',
              txid:     '76b0e88cdb624d3d10122c6dfcb75c379df0f4faf27cb4dbb848ea560dd611fa'
          }
        ]
      end

      let(:currency) { Currency.find_by_id(:btc) }

      let!(:payment_address) do
        create(:btc_payment_address, address: '2MvCSzoFbQsVCTjN2rKWPuHa3THXSp1mHWt')
      end

      before do
        # Mock requests and methods.
        client.class.any_instance.stubs(:latest_block_number).returns(latest_block)
        client.class.any_instance.stubs(:get_block_hash).returns(block_data[0]["result"]["hash"], block_data[1]["result"]["hash"])
        client.class.any_instance.stubs(:get_block).returns(block_data[0]["result"], block_data[1]["result"])

        # Process blockchain data.
        BlockchainService[blockchain.key].process_blockchain
      end

      subject { Deposits::Coin.where(currency: currency) }

      it 'creates two deposit' do
        expect(Deposits::Coin.where(currency: currency).count).to eq expected_deposits.count
      end

      it 'creates deposits with correct attributes' do
        expected_deposits.each do |expected_deposit|
          expect(subject.where(expected_deposit).count).to eq 1
        end
      end

      context 'we process same data one more time' do
        before do
          blockchain.update(height: start_block)
        end

        it 'doesn\'t change deposit' do
          expect(blockchain.height).to eq start_block
          expect{ BlockchainService[blockchain.key].process_blockchain}.not_to change{subject}
        end
      end
    end
  end
end
