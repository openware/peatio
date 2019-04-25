describe Bitcoin::Blockchain do
  context :features do
    it 'defaults' do
      blockchain1 = Bitcoin::Blockchain.new
      expect(blockchain1.features).to eq Bitcoin::Blockchain::DEFAULT_FEATURES
    end

    it 'override defaults' do
      blockchain2 = Bitcoin::Blockchain.new(cash_addr_format: true)
      expect(blockchain2.features[:cash_addr_format]).to be_truthy
    end

    it 'custom feautures' do
      blockchain3 = Bitcoin::Blockchain.new(custom_feature: :custom)
      expect(blockchain3.features.keys).to contain_exactly(*Bitcoin::Blockchain::SUPPORTED_FEATURES)
    end
  end

  context :configure do
    let(:blockchain) { Bitcoin::Blockchain.new }
    it 'default settings' do
      expect(blockchain.settings).to eq({})
    end

    it 'currencies and server configuration' do
      currencies = Currency.where(type: :coin).first(2).map(&:to_blockchain_api_settings)
      settings = { server: 'http://user:password@127.0.0.1:18332',
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

    let(:server) { 'http://user:password@127.0.0.1:18332' }
    let(:blockchain) do
      Bitcoin::Blockchain.new.tap {|b| b.configure(server: server)}
    end

    it 'returns latest block number' do
      block_number = 1489174

      stub_request(:post, 'http://127.0.0.1:18332')
        .with(body: { jsonrpc: '1.0',
                      method: :getblockcount,
                      params:  [] }.to_json)
        .to_return(body: { result: block_number,
                           error:  nil,
                           id:     nil }.to_json)

      expect(blockchain.latest_block_number).to eq(block_number)
    end

    it 'raises error if there is error in response body' do
      stub_request(:post, 'http://127.0.0.1:18332')
        .with(body: { jsonrpc: '1.0',
                      method: :getblockcount,
                      params:  [] }.to_json)
        .to_return(body: { result: nil,
                           error:  { code: -32601, message: 'Method not found' },
                           id:     nil }.to_json)

      expect{ blockchain.latest_block_number }.to raise_error(Peatio::Blockchain::ClientError)
    end
  end

  context :fetch_block! do
    around do |example|
      WebMock.disable_net_connect!
      example.run
      WebMock.allow_net_connect!
    end

    let(:block_file_name) { '1354419-1354420.json' }
    let(:block_data) do
      Rails.root.join('spec', 'resources', 'bitcoin-data', block_file_name)
        .yield_self { |file_path| File.open(file_path) }
        .yield_self { |file| JSON.load(file) }
    end

    let(:start_block)   { block_data.first['result']['height'] }
    let(:latest_block)  { block_data.last['result']['height'] }

    def request_block_hash_body(block_height)
      { jsonrpc: '1.0',
        method: :getblockhash,
        params:  [block_height]
      }.to_json
    end

    def request_block_body(block_hash)
      { jsonrpc: '1.0',
        method:  :getblock,
        params:  [block_hash, 2]
      }.to_json
    end

    before do
      block_data.each do |blk|
        # stub get_block_hash
        stub_request(:post, endpoint)
          .with(body: request_block_hash_body(blk['result']['height']))
          .to_return(body: {result: blk['result']['hash']}.to_json)

        # stub get_block
        stub_request(:post, endpoint)
          .with(body: request_block_body(blk['result']['hash']))
          .to_return(body: blk.to_json)
      end
    end

    let(:currency) do
      Currency.find_by(id: :btc)
    end

    let(:server) { 'http://user:password@127.0.0.1:18332' }
    let(:endpoint) { 'http://127.0.0.1:18332' }
    let(:blockchain) do
      Bitcoin::Blockchain.new.tap { |b| b.configure(server: server, currencies: [currency]) }
    end

    context 'first block' do
      subject { blockchain.fetch_block!(start_block) }

      it 'builds expected number of transactions' do
        expect(subject.count).to eq(14)
      end

      it 'all transactions are valid' do
        expect(subject.all?(&:valid?)).to be_truthy
      end
    end

    context 'last block' do
      subject { blockchain.fetch_block!(latest_block) }

      it 'builds expected number of transactions' do
        expect(subject.count).to eq(20)
      end

      it 'all transactions are valid' do
        expect(subject.all?(&:valid?)).to be_truthy
      end
    end
  end

  context :build_transaction do

    let(:tx_file_name) { '1858591d8ce638c37d5fcd92b9b33ee96be1b950e593cf0cbf45e6bfb1ad8a22.json' }

    let(:tx_hash) do
      Rails.root.join('spec', 'resources', 'bitcoin-data', tx_file_name)
        .yield_self { |file_path| File.open(file_path) }
        .yield_self { |file| JSON.load(file) }
    end
    let(:expected_transactions) do
      [{:hash=>"1858591d8ce638c37d5fcd92b9b33ee96be1b950e593cf0cbf45e6bfb1ad8a22",
        :txout=>0,
        :to_address=>"mg4KVGerD3rYricWC8CoBaayDp1YCKMfvL",
        :amount=>0.325e0,
        :status=>"success",
        :currency_id=>currency.id},
       {:hash=>"1858591d8ce638c37d5fcd92b9b33ee96be1b950e593cf0cbf45e6bfb1ad8a22",
        :txout=>1,
        :to_address=>"mqaBwWDjJCE2Egsf6pfysgD5ZBrfsP7NkA",
        :amount=>0.1964466932e2,
        :status=>"success",
        :currency_id=>currency.id}]
    end

    let(:currency) do
      Currency.find_by(id: :btc)
    end

    let(:blockchain) do
      Bitcoin::Blockchain.new.tap { |b| b.configure(currencies: [currency.to_blockchain_api_settings]) }
    end

    it 'builds formatted transactions for passed transaction' do
      expect(blockchain.send(:build_transaction, tx_hash)).to contain_exactly(*expected_transactions)
    end

    context 'multiple currencies' do
      let(:expected_transactions) do
        [{:hash=>"1858591d8ce638c37d5fcd92b9b33ee96be1b950e593cf0cbf45e6bfb1ad8a22",
          :txout=>0,
          :to_address=>"mg4KVGerD3rYricWC8CoBaayDp1YCKMfvL",
          :amount=>0.325e0,
          :status=>"success",
          :currency_id=>currency1.id},
         {:hash=>"1858591d8ce638c37d5fcd92b9b33ee96be1b950e593cf0cbf45e6bfb1ad8a22",
          :txout=>1,
          :to_address=>"mqaBwWDjJCE2Egsf6pfysgD5ZBrfsP7NkA",
          :amount=>0.1964466932e2,
          :status=>"success",
          :currency_id=>currency1.id},
         {:hash=>"1858591d8ce638c37d5fcd92b9b33ee96be1b950e593cf0cbf45e6bfb1ad8a22",
          :txout=>0,
          :to_address=>"mg4KVGerD3rYricWC8CoBaayDp1YCKMfvL",
          :amount=>0.325e0,
          :status=>"success",
          :currency_id=>currency2.id},
         {:hash=>"1858591d8ce638c37d5fcd92b9b33ee96be1b950e593cf0cbf45e6bfb1ad8a22",
          :txout=>1,
          :to_address=>"mqaBwWDjJCE2Egsf6pfysgD5ZBrfsP7NkA",
          :amount=>0.1964466932e2,
          :status=>"success",
          :currency_id=>currency2.id}]
      end

      let(:currency1) do
        Currency.find_by(id: :btc)
      end

      let(:currency2) do
        Currency.find_by(id: :btc)
      end

      let(:blockchain) do
        Bitcoin::Blockchain.new.tap do |b|
          b.configure(currencies: [currency1.to_blockchain_api_settings, currency2.to_blockchain_api_settings])
        end
      end

      it 'builds formatted transactions for passed transaction per each currency' do
        expect(blockchain.send(:build_transaction, tx_hash)).to contain_exactly(*expected_transactions)
      end
    end

    context 'three vout transaction' do
      let(:tx_file_name) { '1da5cd163a9aaf830093115ac3ac44355e0bcd15afb59af78f84ad4084973ad0.json' }

      let(:expected_transactions) do
        [{:hash=>"1da5cd163a9aaf830093115ac3ac44355e0bcd15afb59af78f84ad4084973ad0",
          :txout=>0,
          :to_address=>"2N5WyM3QT1Kb6fvkSZj3Xvcx2at7Ydm5VmL",
          :amount=>0.1e0,
          :status=>"success",
          :currency_id=>"btc"},
         {:hash=>"1da5cd163a9aaf830093115ac3ac44355e0bcd15afb59af78f84ad4084973ad0",
          :txout=>1,
          :to_address=>"2MzDFuDK9ZEEiRsuCDFkPdeHQLGvwbC9ufG",
          :amount=>0.2e0,
          :status=>"success",
          :currency_id=>"btc"},
         {:hash=>"1da5cd163a9aaf830093115ac3ac44355e0bcd15afb59af78f84ad4084973ad0",
          :txout=>2,
          :to_address=>"2MuvCKKi1MzGtvZqvcbqn5twjA2v5XLaTWe",
          :amount=>0.11749604e0,
          :status=>"success",
          :currency_id=>"btc"}]
      end

      it 'builds formatted transactions for each vout' do
        expect(blockchain.send(:build_transaction, tx_hash)).to contain_exactly(*expected_transactions)
      end
    end
  end
end
