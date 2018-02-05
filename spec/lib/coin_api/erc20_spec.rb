# frozen_string_literal: true

RSpec.describe CoinAPI::ERC20 do
  let(:erc20) { CoinAPI[:erc20] }

  describe '#load_balance!' do
    subject(:load_balance!) do
      erc20.load_balance!
    end

    before do
      # stub eth_coinbase
      stub_request(:post, 'http://127.0.0.1:8545/')
        .with(
          body: {
            jsonrpc: '2.0',
            method: 'eth_coinbase',
            params: [],
            id: 1
          }.to_json
        )
        .to_return(
          body: {
            jsonrpc: '2.0',
            id: 1,
            result: '0x89Af4bF02126b56fc2c24BC324154fF3628Bd946'
          }.to_json
        )

      # stub web3_sha3 request
      stub_request(:post, 'http://127.0.0.1:8545/')
        .with(
          body: {
            jsonrpc: '2.0',
            method: 'web3_sha3',
            params: %w[0x62616c616e63654f66286164647265737329],
            id: 2
          }.to_json
        )
        .to_return(
          body: {
            jsonrpc: '2.0',
            id: 2,
            result: '0x70a08231b98ef4ca268c9cc3f6b4590e4bfec28280db06bb5d45e689f2a360be'
          }.to_json
        )

      # stub eth_call request
      stub_request(:post, 'http://127.0.0.1:8545/')
        .with(
          body: {
            jsonrpc: '2.0',
            method: 'eth_call',
            params: [
              {
                to: '0x6a472aab762eabd632818d07d3c46b4bca6ae733',
                data: '0x70a0823100000000000000000000000089Af4bF02126b56fc2c24BC324154fF3628Bd946'
              },
              'latest'
            ],
            id: 3
          }.to_json
        )
        .to_return(
          body: {
            jsonrpc: '2.0',
            id: 3,
            result: '0x0000000000000000000000000000000000000000000037712ea5f4c8d6a80000'
          }.to_json
        )
    end

    it 'returns balance' do
      expect(load_balance!).to eq(261_818.0)
    end
  end

  describe '#load_deposit!' do
    subject(:load_deposit!) do
      erc20.load_deposit!(txid)
    end

    let(:txid) { '0xa4c2bdbe4ff397d7d3a1fb18422be513eceeccd4abe76e84fcb38fa87547dcbe' }

    before do
      # stub eth_getTransactionByHash request
      stub_request(:post, 'http://127.0.0.1:8545/')
        .with(
          body: {
            jsonrpc: '2.0',
            method: 'eth_getTransactionByHash',
            params: %w[0xa4c2bdbe4ff397d7d3a1fb18422be513eceeccd4abe76e84fcb38fa87547dcbe],
            id: 1
          }.to_json
        )
        .to_return(
          body: {
            jsonrpc: '2.0',
            id: 1,
            result: {
              blockHash: '0x54b57d657de213acbe5c6df88370d03429f0ea0ed25f116cfde7e16de14b7fce',
              blockNumber: '0x16074d',
              from: '0x89af4ef02126b56fc9c24fc324154ff3628bd946',
              gas: '0x2e2c3',
              gasPrice: '0x4e6d5aa1a',
              hash: '0xa4c2bdbe4ff397d7d3a1fb18422be513eceeccd4abe76e84fcb38fa87547dcbe',
              input: '0xa9059cbb000000000000000000000000dccfff1506a8518abf4102cae582eb7ce7972460000000000000000000000000000000000000000000000001a055690d9db80000',
              nonce: '0x38',
              to: '0x6a472aab862eabc632818d07d3c46a4bca6ae561',
              transactionIndex: '0x1',
              value: '0x0',
              v: '0x2c',
              r: '0x97e3f71d9bb49c165eb36f06af4a5f823d6a443c022a9b6230254545e4841627',
              s: '0x28d7eec371eededfdc9dd1a7f315f8aded4518a4c2ce47b082215f52a871389f'
            }
          }.to_json
        )
    end

    before do
      stub_request(:post, 'http://127.0.0.1:8545/')
        .with(
          body: {
            jsonrpc: '2.0',
            method: 'eth_blockNumber',
            params: [],
            id: 2
          }.to_json
        )
        .to_return(
          body: {
            jsonrpc: '2.0',
            id: 2,
            result: '0x1a26ae'
          }.to_json
        )
    end

    it 'returns deposit hash' do
      expect(load_deposit!).to eq(
        id: '0xa4c2bdbe4ff397d7d3a1fb18422be513eceeccd4abe76e84fcb38fa87547dcbe',
        confirmations: 270_177,
        entries: [
          {
            amount: 30.0,
            address: '0xdccfff1506a8518abf4102cae582eb7ce7972460'
          }
        ]
      )
    end
  end

  describe '#inspect_address!' do
    subject(:inspect_address!) do
      erc20.inspect_address!(address)
    end

    let(:address) { '0x89Af4bF02126b56fc2c24BC324154fF3628Bd946' }

    before do
      # stub eth_coinbase
      stub_request(:post, 'http://127.0.0.1:8545/')
        .with(
          body: {
            jsonrpc: '2.0',
            method: 'eth_coinbase',
            params: [],
            id: 1
          }.to_json
        )
        .to_return(
          body: {
            jsonrpc: '2.0',
            id: 1,
            result: '0x89Af4bF02126b56fc2c24BC324154fF3628Bd946'
          }.to_json
        )
    end

    it 'returns address info' do
      expect(inspect_address!).to eq(
        address: '0x89Af4bF02126b56fc2c24BC324154fF3628Bd946',
        is_valid: true,
        is_mine: true
      )
    end

    context 'when address invalid' do
      let(:address) { '123' }

      it 'returns address info with invalid address' do
        expect(inspect_address!).to eq(
          address: '123',
          is_valid: false,
          is_mine: false
        )
      end
    end

    context 'when address not mine' do
      let(:address) { '0x89Af4bF02126b56fc2c24BC324124fF3628Bd946' }

      it 'returns address info with invalid address' do
        expect(inspect_address!).to eq(
          address: '0x89Af4bF02126b56fc2c24BC324124fF3628Bd946',
          is_valid: true,
          is_mine: false
        )
      end
    end
  end

  describe '#create_withdrawal!' do
    subject(:create_withdrawal!) do
      erc20.create_withdrawal!(issuer, recipient, amount, fee)
    end

    let(:issuer) { {address: '0x89Af4bF02126b56fc2c24BC324154fF3628Bd946'} }
    let(:recipient) { {address: '0x3a672aab262eabc632818d07d3c46a4bca6be123'} }
    let(:amount) { 30_000 }
    let(:fee) { 1000 }

    before do
      # stub web3_sha3 request
      stub_request(:post, 'http://127.0.0.1:8545/')
        .with(
          body: {
            jsonrpc: '2.0',
            method: 'web3_sha3',
            params: %w[0x7472616e7366657228616464726573732c75696e7432353629],
            id: 1
          }.to_json
        )
        .to_return(
          body: {
            jsonrpc: '2.0',
            id: 1,
            result: '0xa9059cbb2ab09eb219583f4a59a5d0623ade346d962bcd4e46b11da047c9049b'
          }.to_json
        )

      # stub eth_coinbase
      stub_request(:post, 'http://127.0.0.1:8545/')
        .with(
          body: {
            jsonrpc: '2.0',
            method: 'eth_coinbase',
            params: [],
            id: 2
          }.to_json
        )
        .to_return(
          body: {
            jsonrpc: '2.0',
            id: 2,
            result: '0x89Af4bF02126b56fc2c24BC324154fF3628Bd946'
          }.to_json
        )

        stub_request(:post, 'http://127.0.0.1:8545/')
          .with(
            body: {
              jsonrpc: '2.0',
              method: 'eth_sendTransaction',
              params: [
                {
                  from: '0x89Af4bF02126b56fc2c24BC324154fF3628Bd946',
                  to: '0x6a472aab762eabd632818d07d3c46b4bca6ae733',
                  data: '0xa9059cbb0000000000000000000000003a672aab262eabc632818d07d3c46a4bca6be1230000000000000000000000000000000000000000000000000000000000007530',
                  gas: '0x3e8'
                }
              ],
              id: 3
            }.to_json
          )
          .to_return(
            body: {
              id: 3,
              jsonrpc: '2.0',
              result: '0xe670ec64341771606e55d6b4ca35a1a6b75ee3d5145a99d05921026d1527331'
            }.to_json
          )
    end

    it 'creates withdrawal' do
      expect(create_withdrawal!).to eq(
        '0xe670ec64341771606e55d6b4ca35a1a6b75ee3d5145a99d05921026d1527331'
      )
    end
  end
end
