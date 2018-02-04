# frozen_string_literal: true

RSpec.describe CoinAPI::ETH do
  let(:eth) { CoinAPI[:eth] }

  describe '#load_balance!' do
    subject(:load_balance!) do
      eth.load_balance!
    end

    let(:request_body) do
      {
        jsonrpc: '2.0',
        method: 'eth_getBalance',
        params: %w[0xb3b89717c0cbbce35972d8a8f75bc9cd20748a91 latest],
        id: 1
      }.to_json
    end

    let(:response_body) do
      {
        jsonrpc: '2.0',
        id: 1,
        result: '0x28d2360052d640e0'
      }.to_json
    end

    before do
      stub_request(:post, 'http://127.0.0.1:8545/')
        .with(body: request_body)
        .to_return(body: response_body)
    end

    it 'returns balance' do
      expect(load_balance!).to eq(2.941472881644028)
    end
  end
end
