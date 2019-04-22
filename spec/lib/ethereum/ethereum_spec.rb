describe Ethereum1::Blockchain do

  let(:eth) do
    Currency.find_by(id: :eth)
  end

  let(:trst) do
    Currency.find_by(id: :trst)
  end

  let(:ring) do
    Currency.find_by(id: :ring)
  end

  let(:blockchain) do
    Ethereum1::Blockchain.new.tap { |b| b.configure(server: server, currencies: [eth.to_blockchain_api_settings, trst.to_blockchain_api_settings, ring.to_blockchain_api_settings]) }
  end

  let(:server) { 'http://127.0.0.1:8545' }
  let(:endpoint) { 'http://127.0.0.1:8545' }

  context :features do
    it 'defaults' do
      blockchain1 = Ethereum1::Blockchain.new
      expect(blockchain1.features).to eq Ethereum1::Blockchain::DEFAULT_FEATURES
    end

    it 'override defaults' do
      blockchain2 = Ethereum1::Blockchain.new(cash_addr_format: true)
      expect(blockchain2.features[:cash_addr_format]).to be_truthy
    end

    it 'custom feautures' do
      blockchain3 = Ethereum1::Blockchain.new(custom_feature: :custom)
      expect(blockchain3.features.keys).to contain_exactly(*Ethereum1::Blockchain::SUPPORTED_FEATURES)
    end
  end

  context :configure do
    let(:blockchain) { Ethereum1::Blockchain.new }
    it 'default settings' do
      expect(blockchain.settings).to eq({})
    end

    it 'currencies and server configuration' do
      currencies = Currency.where(type: :coin).first(2).map(&:to_blockchain_api_settings)
      settings = { server: server,
                   currencies: currencies,
                   something: :custom }
      blockchain.configure(settings)
      expect(blockchain.settings).to eq(settings.slice(*Peatio::Blockchain::Abstract::SUPPORTED_SETTINGS))
    end
  end

  context :latest_block_number do
    around do |example|
      WebMock.disable_net_connect!
      example.run
      WebMock.allow_net_connect!
    end

    let(:blockchain) do
      Ethereum1::Blockchain.new.tap { |b| b.configure(server: server) }
    end

    let(:method) { :eth_blockNumber }

    it 'returns latest block number' do
      block_number = '0x16b916'

      stub_request(:post, 'http://127.0.0.1:8545')
        .with(body: { jsonrpc: '2.0',
                      id: 1,
                      method: :eth_blockNumber,
                      params:  [] }.to_json)
        .to_return(body: { result: block_number,
                           error:  nil,
                           id:     1 }.to_json)

      expect(blockchain.latest_block_number).to eq(block_number.to_i(16))
    end

    it 'raises error if there is error in response body' do
      stub_request(:post, 'http://127.0.0.1:8545')
        .with(body: { jsonrpc: '2.0',
                      id: 1,
                      method: method,
                      params:  [] }.to_json)
        .to_return(body: { jsonrpc: '2.0',
                           id: 1,
                           error:  { code: -32601, message: "The method #{method} does not exist/is not available" },
                           id:     1 }.to_json)

      expect{ blockchain.latest_block_number }.to raise_error(Ethereum1::Client::ResponseError)
    end
  end

  context :fetch_block! do
    around do |example|
      WebMock.disable_net_connect!
      example.run
      WebMock.allow_net_connect!
    end

    let(:block_file_name) { '2621840-2621842.json' }

    let(:block_data) do
      Rails.root.join('spec', 'resources', 'ethereum-data', 'rinkeby', block_file_name)
        .yield_self { |file_path| File.open(file_path) }
        .yield_self { |file| JSON.load(file) }
    end

    let(:transaction_receipt_data) do
      Rails.root.join('spec', 'resources', 'ethereum-data', 'rinkeby/transaction-receipts', block_file_name)
          .yield_self { |file_path| File.open(file_path) }
          .yield_self { |file| JSON.load(file) }
    end

    let(:start_block)   { block_data.first['result']['number'].hex }
    let(:latest_block)  { block_data.last['result']['number'].hex }

    def request_block_body(block_height)
      { jsonrpc: '2.0',
        id:     1,
        method: :eth_getBlockByNumber,
        params:  [block_height, true]
      }.to_json
    end

    def request_receipt_block_body(block_hash)
      { jsonrpc: '2.0',
        id:      1,
        method:  :eth_getTransactionReceipt,
        params:  [block_hash]
      }.to_json
    end

    before do
      Ethereum1::Client.any_instance.stubs(:rpc_call_id).returns(1)
      block_data.each do |blk|
        # stub get_block_hash
        stub_request(:post, endpoint)
          .with(body: request_block_body(blk['result']['number']))
          .to_return(body: blk.to_json )
      end

      transaction_receipt_data.each do |blk|
        # stub get_receipt
        stub_request(:post, endpoint)
          .with(body: request_receipt_block_body(blk['result']['transactionHash']))
          .to_return(body: blk.to_json)
      end
    end

    context 'first block' do

      let(:expected_transactions) do
        [{:hash=>"0xb60e22c6eed3dc8cd7bc5c7e38c50aa355c55debddbff5c1c4837b995b8ee96d",
          :amount=>1.to_d,
          :to_address=>"0xe3cb6897d83691a8eb8458140a1941ce1d6e6daa",
          :txout=>26,
          :block_number=>2621840,
          :status=>"success",
          :currency_id=>eth.id}]
      end

      subject { blockchain.fetch_block!(start_block) }

      it 'builds expected number of transactions' do
        subject.transactions.each_with_index do |t, i|
          expect(t.as_json).to eq(expected_transactions[i].as_json)
        end
      end

      it 'all transactions are valid' do
        expect(subject.all?(&:valid?)).to be_truthy
      end
    end

    context 'last block' do
      subject { blockchain.fetch_block!(latest_block) }

      let(:expected_transactions) do
        [{:hash=>"0x0338e2a59db18596afff8b7a0db3669cc231c7333064640bedf3a73c1c1c31ed",
          :amount=>18.75.to_d,
          :to_address=>"0xc4d276bf32b71cdddb18f3b4d258f057a5ffda03",
          :txout=>13,
          :block_number=>2621842,
          :status=>"success",
          :currency_id=>eth.id},
         {:hash=>"0x826555325cec51c4d39b327e563ce3e8ee87e27be5911383f528724a62f0da5d",
          :amount=>2.to_d,
          :to_address=>"0xe3cb6897d83691a8eb8458140a1941ce1d6e6daa",
          :txout=>8,
          :block_number=>2621842,
          :status=>"success",
          :currency_id=>trst.id},
         {:hash=>"0x826555325cec51c4d39b327e563ce3e8ee87e27be5911383f528724a62f0da5d",
          :amount=>2.to_d,
          :to_address=>"0x4b6a630ff1f66604d31952bdce2e4950efc99821",
          :txout=>9,
          :block_number=>2621842,
          :status=>"success",
          :currency_id=>ring.id},
         {:hash=>"0xd5cc0d1d5dd35f4b57572b440fb4ef39a4ab8035657a21692d1871353bfbceea",
          :amount=>2.to_d,
          :to_address=>"0xe3cb6897d83691a8eb8458140a1941ce1d6e6dac",
          :txout=>9,
          :block_number=>2621842,
          :status=>"success",
          :currency_id=>trst.id}]
      end

      it 'builds expected number of transactions' do
        subject.transactions.each_with_index do |t, i|
          expect(t.as_json).to eq(expected_transactions[i].as_json)
        end
      end

      it 'all transactions are valid' do
        expect(subject.all?(&:valid?)).to be_truthy
      end
    end
  end

  context :build_transaction do

    context :eth_transaction do

      let(:tx_file_name) { '0xb60e22c6eed3dc8cd7bc5c7e38c50aa355c55debddbff5c1c4837b995b8ee96d.json' }

      let(:tx_hash) do
        Rails.root.join('spec', 'resources', 'ethereum-data', 'rinkeby', 'transactions', tx_file_name)
          .yield_self { |file_path| File.open(file_path) }
          .yield_self { |file| JSON.load(file) }
      end
      let(:expected_transactions) do
        [{:hash=>"0xb60e22c6eed3dc8cd7bc5c7e38c50aa355c55debddbff5c1c4837b995b8ee96d",
          :to_address=>"0xe3cb6897d83691a8eb8458140a1941ce1d6e6daa",
          :txout=>26,
          :amount=>1.to_d,
          :block_number=>2621840,
          :status=>"success",
          :currency_id=>eth.id}]
      end

      it 'builds formatted transactions for passed transaction' do
        expect(blockchain.send(:build_transactions, tx_hash)).to contain_exactly(*expected_transactions)
      end
    end

    context :erc20_transaction do

      let(:tx_file_name) { '0x826555325cec51c4d39b327e563ce3e8ee87e27be5911383f528724a62f0da5d.json' }

      let(:tx_hash) do
        Rails.root.join('spec', 'resources', 'ethereum-data', 'rinkeby', 'transactions', tx_file_name)
          .yield_self { |file_path| File.open(file_path) }
          .yield_self { |file| JSON.load(file) }
      end

      let(:expected_transactions) do
        [{:hash=>"0x826555325cec51c4d39b327e563ce3e8ee87e27be5911383f528724a62f0da5d",
          :to_address=>"0xe3cb6897d83691a8eb8458140a1941ce1d6e6daa",
          :amount=>2.to_d,
          :currency_id=>trst.id,
          :block_number=>2621842,
          :status=>"success",
          :txout=>8},
         {:hash=>"0x826555325cec51c4d39b327e563ce3e8ee87e27be5911383f528724a62f0da5d",
          :to_address=>"0x4b6a630ff1f66604d31952bdce2e4950efc99821",
          :amount=>2.to_d,
          :currency_id=>ring.id,
          :block_number=>2621842,
          :status=>"success",
          :txout=>9}]
      end

      it 'builds formatted transactions for passed transaction' do
        expect(blockchain.send(:build_transactions, tx_hash)).to contain_exactly(*expected_transactions)
      end
    end
  end
end
