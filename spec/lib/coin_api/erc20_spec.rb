describe CoinAPI::ERC20 do
  let(:client) { CoinAPI[:trst] }

  around do |example|
    WebMock.disable_net_connect!
    example.run
    WebMock.allow_net_connect!
  end

  describe '#create_address!' do
    subject { client.create_address! }

    let :request_body do
      { jsonrpc: '2.0',
        id:      1,
        method:  'personal_newAccount',
        params:  %w[ pass@word ]
      }.to_json
    end

    let :response_body do
      { jsonrpc: '2.0',
        id:      1,
        result:  '0x42eb768f2244c8811c63729a21a3569731535f06'
      }.to_json
    end

    before do
      Passgen.stubs(:generate).returns('pass@word')
      stub_request(:post, 'http://127.0.0.1:8545/').with(body: request_body).to_return(body: response_body)
    end

    it { is_expected.to eq(address: '0x42eb768f2244c8811c63729a21a3569731535f06', secret: 'pass@word') }
  end

  describe '#load_balance!' do
    subject(:load_balance!) { client.load_balance! }

    let :request_body do
      { jsonrpc: '2.0',
        id:      1,
        method:  'eth_call',
        params:  [{ to:   '0x87099add3bcc0821b5b151307c147215f839a110',
                    data: '0x' + '70a0823100000000000000000000000042eb768f2244c8811c63729a21a3569731535f06'
                  }, 'latest']
      }.to_json
    end

    let :response_body do
      { jsonrpc: '2.0',
        id:      1,
        result:  '0x0000000000000000000000000000000000000000000000000000000000000000'
      }.to_json
    end

    before do
      create(:payment_address, currency: client.currency, address: '0x42eb768f2244c8811c63729a21a3569731535f06')
      stub_request(:post, 'http://127.0.0.1:8545/').with(body: request_body).to_return(body: response_body)
    end
    it 'returns balance' do
      expect(load_balance!).to eq('0.0'.to_d)
    end
  end

  describe '#inspect_address!' do
    context 'valid address' do
      let(:address) { '0x42eb768f2244c8811c63729a21a3569731535f06' }
      subject { client.inspect_address!(address) }
      it { is_expected.to eq({ address: address, is_valid: true, is_mine: :unsupported }) }
    end

    context 'invalid address' do
      let(:address) { '0x729a21a3569731535f06' }
      subject { client.inspect_address!(address) }
      it { is_expected.to eq({ address: address, is_valid: false, is_mine: :unsupported }) }
    end
  end

  describe '#each_deposit!' do
    subject { client.each_deposit! }

    let :request_body do
      { jsonrpc: '2.0',
        id:      1,
        method:  'eth_getBlockByNumber',
        params:  ['0x1', true]
      }.to_json
    end

    let :response_body do
      '{"jsonrpc":"2.0","id":1,"result":{"number":"0x1b4","hash":"0xe670ec64341771606e55d6b4ca35a1a6b75ee3d5145a99d05921026d1527331","parentHash":"0x9646252be9520f6e71339a8df9c55e4d7619deeb018d2a3f2d21fc165dde5eb5","nonce":"0xe04d296d2460cfb8472af2c5fd05b5a214109c25688d3704aed5484f9a7792f2","sha3Uncles":"0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347","logsBloom":"0xe670ec64341771606e55d6b4ca35a1a6b75ee3d5145a99d05921026d1527331","transactionsRoot":"0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421","stateRoot":"0xd5855eb08b3387c0af375e9cdb6acfc05eb8f519e419b874b6ff2ffda7ed1dff","miner":"0x4e65fda2159562a496f9f3522f89122a3088497a","difficulty":"0x027f07","totalDifficulty":"0x027f07","extraData":"0x0000000000000000000000000000000000000000000000000000000000000000","size":"0x027f07","gasLimit":"0x9f759","gasUsed":"0x9f759","timestamp":"0x54e34e8e","uncles":["0xb903239f8543d04b5dc1ba6579132b143087c68db1b2168786408fcbce568238"],"transactions":[{"hash":"0xc6ef2fc5426d6ad6fd9e2a26abeab0aa2411b7ab17f30a99d3cb96aed1d1055b","nonce":"0x","blockHash":"0xbeab0aa2411b7ab17f30a99d3cb9c6ef2fc5426d6ad6fd9e2a26a6aed1d1055b","blockNumber":"0x1","transactionIndex":"0x1","from":"0x407d73d8a49eeb85d32cf465507dd71d507100c1","to":"0x87099add3bcc0821b5b151307c147215f839a110","value":"0x7f110","gas":"0x7f110","gasPrice":"0x09184e72a000","input":"a9059cbb000000000000000000000000085h43d8a49eeb85d32cf465507dd71d507100c100000000000000000000000000000000000000000000000000000000001e8480"}]}}'
    end

    before do
      client.expects(:latest_block_number).returns(1)
      stub_request(:post, 'http://127.0.0.1:8545/').with(body: request_body).to_return(body: response_body)
    end

    it do
      is_expected.to eq([{
                           id:            '0xc6ef2fc5426d6ad6fd9e2a26abeab0aa2411b7ab17f30a99d3cb96aed1d1055b',
                           confirmations: 0,
                           received_at:   Time.at(0x54e34e8e),
                           entries:       [{ address: '0x85h43d8a49eeb85d32cf465507dd71d507100c10',
                                             amount:  '2.0'.to_d }]
                         }])
    end
  end

  describe '#load_deposit!' do
    subject { client.load_deposit!(hash) }

    let(:hash) { '0xc496f09c00916b4e40f2ae6e05d3c8927689e4b447e914064fb9213c380bf965' }

    let :request_body do
      { jsonrpc: '2.0',
        id:      1,
        method:  'eth_getTransactionReceipt',
        params:  [hash]
      }.to_json
    end

    let :response_body do
      '{"jsonrpc":"2.0","id":1,"result":{"blockHash":"0x2327990cda5c1ea2968b7e9b8913fae81efbd36a5aa1789d3ba5dfbbc1548f76","blockNumber":"0x20ccf8","cumulativeGasUsed":"0xc8e1","from":"0xdd61c7d5a1213af4a7b589f6e557cce3fcc0cfbb","gasUsed":"0xc8e1","logs":[{"address":"0x87099add3bcc0821b5b151307c147215f839a110","topics":["0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef","0x000000000000000000000000dd61c7d5a1213af4a7b589f6e557cce3fcc0cfbb","0x000000000000000000000000785529cc54014e00bb3bbfe4f18cec960e72a401"],"data":"0x00000000000000000000000000000000000000000000000000000000000f4240","blockNumber":"0x20ccf8","transactionHash":"0xc496f09c00916b4e40f2ae6e05d3c8927689e4b447e914064fb9213c380bf965","transactionIndex":"0x0","blockHash":"0x2327990cda5c1ea2968b7e9b8913fae81efbd36a5aa1789d3ba5dfbbc1548f76","logIndex":"0x0","removed":false}],"logsBloom":"0x00000000000000004000000000000000000000000000000000001000000000000010000000000000000000000000000000000000000000000200000000000000000000000000000000000008000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000010000000000000000000000000000000000200000000000000000000000000000000000000000200000000000000002000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000","status":"0x1","to":"0x87099add3bcc0821b5b151307c147215f839a110","transactionHash":"0xc496f09c00916b4e40f2ae6e05d3c8927689e4b447e914064fb9213c380bf965","transactionIndex":"0x0"}}'
    end

    before do
      client.expects(:latest_block_number).returns(2166994)
      stub_request(:post, 'http://127.0.0.1:8545/').with(body: request_body).to_return(body: response_body)
    end

    it do
      is_expected.to eq \
        id:            '0xc496f09c00916b4e40f2ae6e05d3c8927689e4b447e914064fb9213c380bf965',
        confirmations: 17370,
        entries:       [{ amount: '1.0'.to_d, address: '0x785529cc54014e00bb3bbfe4f18cec960e72a401' }]
    end
  end

  describe 'create_withdrawal!' do
    subject { client.create_withdrawal!(issuer, recipient, 10) }

    let(:issuer) { { address: '0x785529cc54014e00bb3bbfe4f18cec960e72a401', secret: 'guz@?I0cYav)9b0bk1#(%Tol#TtY5hOLYg7NWq+G#6X%1fTqXz!h4Egjl84HE3ws' } }
    let(:recipient) { { address: '0xDD61C7D5a1213AF4A7b589F6E557cCe3fCC0cfbB' } }

    let :request_body do
      { jsonrpc: '2.0',
        id:      1,
        method:  'eth_sendTransaction',
        params:  [from: '0x785529cc54014e00bb3bbfe4f18cec960e72a401',
                  to:   '0x87099add3bcc0821b5b151307c147215f839a110',
                  data: '0xa9059cbb000000000000000000000000dd61c7d5a1213af4a7b589f6e557cce3fcc0cfbb0000000000000000000000000000000000000000000000000000000000989680']
      }.to_json
    end

    let :response_body do
      { jsonrpc: '2.0',
        id:      1,
        result:  '0x3d26f9395f564eeb267188b97443b76967a88db62cbd91dec328a31145dde483'
      }.to_json
    end

    before do
      client.expects(:permit_transaction)
      stub_request(:post, 'http://127.0.0.1:8545/').with(body: request_body).to_return(body: response_body)
    end

    it { is_expected.to eq('0x3d26f9395f564eeb267188b97443b76967a88db62cbd91dec328a31145dde483') }
  end
end
