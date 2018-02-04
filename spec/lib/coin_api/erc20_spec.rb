# frozen_string_literal: true

RSpec.describe CoinAPI::ERC20 do
  let(:eth) { CoinAPI[:erc20] }

  describe '#load_balance!' do
    subject(:load_balance!) do
      eth.load_balance!
    end

    before do
      # stub web3_sha3 request
      stub_request(:post, 'http://127.0.0.1:8545/')
        .with(
          body: {
            'jsonrpc': '2.0',
            'method': 'web3_sha3',
            'params': %w[0x62616c616e63654f66286164647265737329],
            'id': 1
          }.to_json
        )
        .to_return(
          body: {
            'jsonrpc': '2.0',
            'id': 1,
            'result': '0x70a08231b98ef4ca268c9cc3f6b4590e4bfec28280db06bb5d45e689f2a360be'
          }.to_json
        )
    end

    before do
      # stub eth_call request
      stub_request(:post, 'http://127.0.0.1:8545/')
        .with(
          body: {
            'jsonrpc': '2.0',
            'method': 'eth_call',
            'params': [
              {
                'to': '0x6a472aab762eabd632818d07d3c46b4bca6ae733',
                'data': '0x70a0823100000000000000000000000089Af4bF02126b56fc2c24BC324154fF3628Bd946'
              },
              'latest'
            ],
            'id': 2
          }.to_json
        )
        .to_return(
          body: {
            'jsonrpc': '2.0',
            'id': 2,
            'result': '0x0000000000000000000000000000000000000000000037712ea5f4c8d6a80000'
          }.to_json
        )
    end

    it 'returns balance' do
      expect(load_balance!).to eq(261_818.0)
    end
  end
end
