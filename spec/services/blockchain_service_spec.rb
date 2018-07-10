# encoding: UTF-8
# frozen_string_literal: true

describe BlockchainService do

  around do |example|
    WebMock.disable_net_connect!
    example.run
    WebMock.allow_net_connect!
  end

  describe 'BlockAPI::Ethereum' do
    let(:block_data) do
      Rails.root.join('spec', 'resources', block_file_name)
        .yield_self { |file_path| File.open(file_path) }
        .yield_self { |file| JSON.load(file) }
    end

    let(:start_block)   { block_data.first['result']['number'].hex }
    let(:latest_block)  { block_data.last['result']['number'].hex }

    let(:blockchain) do
      Blockchain.find_by_key('eth-rinkeby')
        .tap { |b| b.update(height: start_block)}
    end

    let(:client) { BlockAPI[blockchain.key] }

    def request_body(block_number, index)
      { jsonrpc: '2.0',
        id:      index + 1, # json_rpc_call_id increments on each request.
        method:  :eth_getBlockByNumber,
        params:  [block_number, true]
      }.to_json
    end

    context 'single ETH deposit was created during blockchain proccessing' do
      # File with real json rpc data for bunch of blocks.
      let(:block_file_name) { 'ethereum-data.json' }

      # Use rinkeby.etherscan.io to fetch transactions data.
      let(:expected_deposits) do
        [
          {
            amount:   '0xde0b6b3a7640000'.hex.to_d / currency.base_factor,
            address:  '0xe3cb6897d83691a8eb8458140a1941ce1d6e6daa',
            txid:     '0xb60e22c6eed3dc8cd7bc5c7e38c50aa355c55debddbff5c1c4837b995b8ee96d'
          }
        ]
      end

      let(:currency) { Currency.find_by_id(:eth) }

      let!(:payment_address) do
        create(:eth_payment_address, address: '0xe3cb6897d83691a8eb8458140a1941ce1d6e6daa')
      end

      before do
        # Mock requests and methods.
        client.class.any_instance.stubs(:latest_block_number).returns(latest_block)
        block_data.each_with_index do |blk, index|
          stub_request(:post, client.endpoint)
            .with(body: request_body(blk['result']['number'],index))
            .to_return(body: blk.to_json)
        end
        # Process blockchain data.
        BlockchainService.new(blockchain).process_blockchain
      end

      subject { Deposits::Coin.where(currency: currency) }

      it 'creates single deposit' do
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
          expect{ BlockchainService.new(blockchain).process_blockchain}.not_to change{subject}
        end
      end
    end

    context 'two TRST deposits was created during blockchain proccessing' do
      # File with real json rpc data for bunch of blocks.
      let(:block_file_name) { 'ethereum-data.json' }

      # Use rinkeby.etherscan.io to fetch transactions data.
      let(:expected_deposits) do
        [
          {
            amount:   '0x1e8480'.hex.to_d / currency.base_factor,
            address:  '0xe3cb6897d83691a8eb8458140a1941ce1d6e6daa',
            txid:     '0xd5cc0d1d5dd35f4b57572b440fb4ef39a4ab8035657a21692d1871353bfbceea'
          },
          {
            amount:   '0x1e8480'.hex.to_d / currency.base_factor,
            address:  '0xe3cb6897d83691a8eb8458140a1941ce1d6e6daa',
            txid:     '0x826555325cec51c4d39b327e563ce3e8ee87e27be5911383f528724a62f0da5d'
          }
        ]
      end

      let(:currency) { Currency.find_by_id(:trst) }

      let!(:payment_address) do
        create(:trst_payment_address, address: '0xe3cb6897d83691a8eb8458140a1941ce1d6e6daa')
      end

      before do
        # Mock requests and methods.
        client.class.any_instance.stubs(:latest_block_number).returns(latest_block)
        block_data.each_with_index do |blk, index|
          stub_request(:post, client.endpoint)
              .with(body: request_body(blk['result']['number'],index))
              .to_return(body: blk.to_json)
        end
        # Process blockchain data.
        BlockchainService.new(blockchain).process_blockchain
      end

      subject { Deposits::Coin.where(currency: currency) }

      it 'creates two deposits' do
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
          expect{ BlockchainService.new(blockchain).process_blockchain}.not_to change{subject}
        end
      end

    end
  end
end
