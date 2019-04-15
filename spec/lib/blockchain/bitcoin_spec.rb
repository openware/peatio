describe Bitcoin::Blockchain do
  context :features do
    it 'defaults' do
      blockchain1 = Bitcoin::Blockchain.new
      expect(blockchain1.features).to eq Bitcoin::Blockchain::DEFAULT_FEATURES
    end

    it 'override defaults' do
      blockchain2 = Bitcoin::Blockchain.new(supports_cash_addr_format: true)
      expect(blockchain2.features[:supports_cash_addr_format]).to be_truthy
    end

    it 'custom feautures' do
      blockchain3 = Bitcoin::Blockchain.new(custom_feature: :custom)
      expect(blockchain3.features.keys).to contain_exactly(:supports_cash_addr_format, :case_sensitive)
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

      expect{ blockchain.latest_block_number }.to raise_error(Bitcoin::Client::ResponseError)
    end
  end
end
