# encoding: UTF-8
# frozen_string_literal: true

describe WalletService do

  around do |example|
    WebMock.disable_net_connect!
    example.run
    WebMock.allow_net_connect!
  end

  let(:deposit_wallet) { Wallet.find_by(currency: :eth, kind: :deposit) }
  let(:hot_wallet) { Wallet.find_by(currency: :eth, kind: :hot) }
  let(:warm_wallet) { Wallet.find_by(currency: :eth, kind: :warm) }
  let(:deposit) { create(:deposit_xrp, amount: 10) }

  describe 'spread deposit' do

    context 'part to hot and part to warm' do

      let(:deposit) { create(:deposit_eth, amount: 100) }

      let :hot_wallet_balance do
        { result: '32' }.to_json
      end

      let :warm_wallet_balance do
        { result: '0' }.to_json
      end

      let :request_hot_wallet_balance do
        {
          jsonrpc:  '2.0',
          id:       1,
          method:   'eth_getBalance',
          params:   [ hot_wallet[:address].downcase, 'latest' ],
        }.to_json
      end

      let :request_warm_wallet_balance do
        {
          jsonrpc:  '2.0',
          id:       2,
          method:   'eth_getBalance',
          params:   [ warm_wallet[:address].downcase, 'latest' ],
        }.to_json
      end

      let :response_body do
        {
          "0xb6a61c43DAe37c0890936D720DC42b5CBda990F9"=>0.5e2,
          "0x2b9fBC10EbAeEc28a8Fc10069C0BC29E45eBEB9C"=>0.5e2
        }
      end

      subject { WalletService[deposit_wallet].spread_deposit(deposit) }

      before do
        # Hot wallet balance = 50 eth
        stub_request(:post, hot_wallet.uri).with(body: request_hot_wallet_balance).to_return(body: hot_wallet_balance)
        # Warm wallet balance = 0 eth
        stub_request(:post, hot_wallet.uri).with(body: request_warm_wallet_balance).to_return(body: warm_wallet_balance)
      end
      it do
        # Deposit amount 100 eth
        # Collect 50 eth to Hot wallet and 50 eth to Warm wallet
        is_expected.to eq(response_body)
      end
    end

    context 'part to hot and all remains to last wallet (warm)' do

      let(:deposit) { create(:deposit_eth, amount: 200) }

      context 'part to hot and part to warm' do

        let :hot_wallet_balance do
          { result: '32' }.to_json
        end

        let :warm_wallet_balance do
          { result: '0' }.to_json
        end

        let :request_hot_wallet_balance do
          {
            jsonrpc:  '2.0',
            id:       1,
            method:   'eth_getBalance',
            params:   [ hot_wallet[:address].downcase, 'latest' ],
          }.to_json
        end

        let :request_warm_wallet_balance do
          {
            jsonrpc:  '2.0',
            id:       2,
            method:   'eth_getBalance',
            params:   [ warm_wallet[:address].downcase, 'latest' ],
          }.to_json
        end

        let :response_body do
          {
            "0xb6a61c43DAe37c0890936D720DC42b5CBda990F9"=>0.5e2,
            "0x2b9fBC10EbAeEc28a8Fc10069C0BC29E45eBEB9C"=>1.5e2
          }
        end

        subject { WalletService[deposit_wallet].spread_deposit(deposit) }

        before do
          warm_wallet.update!(max_balance: 100)
          # Hot wallet balance = 50 eth
          stub_request(:post, hot_wallet.uri).with(body: request_hot_wallet_balance).to_return(body: hot_wallet_balance)
          # Warm wallet balance = 0 eth
          stub_request(:post, hot_wallet.uri).with(body: request_warm_wallet_balance).to_return(body: warm_wallet_balance)
        end
        it do
          # Deposit amount 200 eth
          # Collect 50 eth to Hot wallet and 150 eth to Warm wallet(last wallet)
          is_expected.to eq(response_body)
        end
      end
    end
  end
end
