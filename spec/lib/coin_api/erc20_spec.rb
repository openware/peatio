# frozen_string_literal: true

RSpec.describe CoinAPI::ERC20 do
  let(:erc20) { CoinAPI[:erc20] }

  around do |example|
    WebMock.disable_net_connect!

    example.run

    WebMock.allow_net_connect!
  end

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
            id: 2
          }.to_json
        )
        .to_return(
          body: {
            jsonrpc: '2.0',
            id: 2,
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

      # stub eth_getTransactionByHash request
      stub_request(:post, 'http://127.0.0.1:8545/')
        .with(
          body: {
            jsonrpc: '2.0',
            method: 'eth_getTransactionReceipt',
            params: %w[0xa4c2bdbe4ff397d7d3a1fb18422be513eceeccd4abe76e84fcb38fa87547dcbe],
            id: 2
          }.to_json
        )
        .to_return(
          body: {
            jsonrpc: '2.0',
            id: 2,
            result: {
              blockHash: "0x23439b3e5b5e76a3f39c1faad21822171d8a228aa4582b3d94d4487b36592498",
              blockNumber: "0x16074d",
              contractAddress: nil,
              cumulativeGasUsed: "0x27d2c6",
              from: "0x89af4ef02126b56fc9c24fc324154ff3628bd946",
              gasUsed: "0x93b9",
              logs: [
                {
                  address: "0x6a472aab862eabc632818d07d3c46a4bca6ae561",
                  topics: [
                    "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef",
                    "0x000000000000000000000000dccfff1506a8518abf4102cae582eb7ce7972460",
                    "0x00000000000000000000000089Af4bF02126b56fc2c24BC324154fF3628Bd946"
                  ],
                  data: "0x000000000000000000000000000000000000000000000001a055690d9db80000",
                  blockNumber: "0x1a31bb",
                  transactionHash: "0x133b177d5462a1b092a74e197d2cd1613b4eb4cf0450db4q0f1c090e37b8b2698",
                  transactionIndex: "0x5",
                  blockHash: "0x23439b3e5b5e76a3f39c1faad21822171d8a228aa4582b3d94d4487b36592498",
                  logIndex: "0x19",
                  removed: false
                }
              ],
              logsBloom: "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000200000000000000000000000000000000000100000000000000000000010040000800000000000000000000000000000000000000000004000000000000000000000002000000000000000000000000000000000000200000000000000000000000000000000000000002000000000000000000000000000000000000000000",
              status: "0x1",
              to: "0x6a472aab862eabc632818d07d3c46a4bca6ae561",
              transactionHash: "0xa4c2bdbe4ff397d7d3a1fb18422be513eceeccd4abe76e84fcb38fa87547dcbe",
              transactionIndex: "0x5"
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
            id: 3
          }.to_json
        )
        .to_return(
          body: {
            jsonrpc: '2.0',
            id: 3,
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
              id: 2
            }.to_json
          )
          .to_return(
            body: {
              id: 2,
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

  describe '#each_deposit!' do
    subject(:each_deposit!) do
      erc20.each_deposit! do |deposit|
        # some functionality
      end
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

      # stub eth_getTransactionByHash request
      stub_request(:post, 'http://127.0.0.1:8545/')
        .with(
          body: {
            jsonrpc: '2.0',
            method: 'eth_getLogs',
            params: [
              {
                address: "0x6a472aab762eabd632818d07d3c46b4bca6ae733",
                topics: [
                  "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef",
                  nil,
                  "0x00000000000000000000000089Af4bF02126b56fc2c24BC324154fF3628Bd946"
                ],
                fromBlock: "earliest",
                toBlock: "latest"
              }
            ],
            id: 2
          }.to_json
        )
        .to_return(
          body: {
            jsonrpc: '2.0',
            id: 2,
            result: [
              {
                address: "0x6a472aab762eabd632818d07d3c46b4bca6ae733",
                topics: [
                  "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef",
                  "0x000000000000000000000000dccfff1506a8518dbf4102cae582ef7ce6975460",
                  "0x00000000000000000000000089af4ef02126b56fc9c24fc324154ff3628bd946"
                ],
                data: "0x00000000000000000000000000000000000000000000d3c21bcecceda1000000",
                blockNumber: "0x137452",
                transactionHash: "0x9ba8182bfb898e67c2634ac1bd36a0fa276fe827a7d7840f0c3bb05f4326783c",
                transactionIndex: "0x2",
                blockHash: "0x33b47301a26288f770891321e7380a63cb62fd35c036901978f57accf3bbae78",
                logIndex: "0x1",
                removed: false
              },
              {
                address: "0x6a472aab762eabd632818d07d3c46b4bca6ae733",
                topics: [
                  "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef",
                  "0x00000000000000000000000098aa80db3a7895c20b72fbbd8764162835f53eb0",
                  "0x00000000000000000000000089af4ef02126b56fc9c24fc324154ff3628bd946"
                ],
                data: "0x000000000000000000000000000000000000000000000001a055690d9db80000",
                blockNumber: "0x16073b",
                transactionHash: "0x8e9bcb3843621cb91a89a221a0c4c29e9ab21a0d81b07f2471cb26f172bff9f3",
                transactionIndex: "0x0",
                blockHash: "0xad837eaf560ed5acc62a3b5956b055a7c1abbf46e8ee5f480a2a38db685bd4e7",
                logIndex: "0x0",
                removed: false
              },
              {
                address: "0x6a472aab762eabd632818d07d3c46b4bca6ae733",
                topics: [
                  "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef",
                  "0x000000000000000000000000f43dac43dbc6da9268c5b26cb25860298b86d965",
                  "0x00000000000000000000000089af4ef02126b56fc9c24fc324154ff3628bd946"
                ],
                data: "0x000000000000000000000000000000000000000000000001a055690d9db80000",
                blockNumber: "0x16075d",
                transactionHash: "0xe2e7acbe6bb0f87f73a0fdce36673160566f8e761c610706ed80f8e473b794e7",
                transactionIndex: "0x0",
                blockHash: "0xeca05788ae00e0ff72c215dfcfc9f2829f20b08260f39b4d2728315bdf144ca2",
                logIndex: "0x0",
                removed: false
              }
            ]
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
            id: 3
          }.to_json
        )
        .to_return(
          body: {
            jsonrpc: '2.0',
            id: 3,
            result: '0x1a26ae'
          }.to_json
        )
    end

    it 'returns deposit hash' do
      expect(each_deposit!).to eq(
        [
          {
            id: "0x9ba8182bfb898e67c2634ac1bd36a0fa276fe827a7d7840f0c3bb05f4326783c",
            confirmations: 438876,
            entries: [
              {
                amount: 1000000.0,
                address: "0xdccfff1506a8518dbf4102cae582ef7ce6975460"
              }
            ]
          },
          {
            id: "0x8e9bcb3843621cb91a89a221a0c4c29e9ab21a0d81b07f2471cb26f172bff9f3",
            confirmations: 270195,
            entries:  [
              {
                amount: 30.0,
                address: "0x98aa80db3a7895c20b72fbbd8764162835f53eb0"
              }
            ]
          },
          {
            id: "0xe2e7acbe6bb0f87f73a0fdce36673160566f8e761c610706ed80f8e473b794e7",
            confirmations: 270161,
            entries: [
              {
                amount: 30.0,
                address: "0xf43dac43dbc6da9268c5b26cb25860298b86d965"
              }
            ]
          }
        ]
      )
    end
  end
end
