# encoding: UTF-8
# frozen_string_literal: true

describe WalletService::Dashd do

  around do |example|
    WebMock.disable_net_connect!
    example.run
    WebMock.allow_net_connect!
  end

  describe 'WalletService::Dashd' do

    let(:deposit) { create(:deposit_dash, amount: 10) }
    let(:withdraw) { create(:dash_withdraw) }
    let(:deposit_wallet) { Wallet.find_by(gateway: :dashd, kind: :deposit) }
    let(:hot_wallet) { Wallet.find_by(gateway: :dashd, kind: :hot) }

    context '#create_address' do
      subject { WalletService[deposit_wallet].create_address }

      let :request_body do
        { jsonrpc: '1.0',
          method: 'getnewaddress',
          params: []
        }.to_json
      end

      let :response_body do
        { result: '2N7r9zKXkypzqtXfWkKfs3uZqKbJUhdK6JE' }.to_json
      end

      before do
        stub_request(:post, deposit_wallet.uri).with(body: request_body).to_return(body: response_body)
      end

      it { is_expected.to eq(address: '2N7r9zKXkypzqtXfWkKfs3uZqKbJUhdK6JE') }
    end

    context '#collect_deposit!' do
      subject { WalletService[deposit_wallet].collect_deposit!(deposit) }

      let(:deposit) { create(:deposit_dash, amount: 10) }
      let :hot_wallet_balance do
        {
            result: '0'
        }.to_json
      end

      let :request_balance do
        {
            jsonrpc:  '1.0',
            method:   'listunspent',
            params:   [1, 10000000, ['yborj44WhothaX6vwoMhRMjkq1xELhAWQp']],
        }.to_json
      end

      let :request_body do
        { jsonrpc: '1.0',
          method: 'sendtoaddress',
          params: [hot_wallet.address, deposit.amount, '', '', true]
        }.to_json
      end

      let :response_body do
        { result: 'dcedf50780f251c99e748362c1a035f2916efb9bb44fe5c5c3e857ea74ca06b3' }.to_json
      end

      before do
        stub_request(:post, hot_wallet.uri).with(body: request_balance).to_return(body: hot_wallet_balance)
        stub_request(:post, deposit_wallet.uri).with(body: request_body).to_return(body: response_body)
      end

      it { is_expected.to eq(['dcedf50780f251c99e748362c1a035f2916efb9bb44fe5c5c3e857ea74ca06b3']) }
    end

    context '#build_withdrawal!' do
      subject { WalletService[hot_wallet].build_withdrawal!(withdraw) }

      let :request_body do
        { jsonrpc: '1.0',
          method: 'sendtoaddress',
          params: [withdraw.rid, withdraw.amount, '', '', false]
        }.to_json
      end

      let :response_body do
        { result: 'dcedf50780f251c99e748362c1a035f2916efb9bb44fe5c5c3e857ea74ca06b3' }.to_json
      end

      before do
        stub_request(:post, hot_wallet.uri).with(body: request_body).to_return(body: response_body)
      end

      it { is_expected.to eq('dcedf50780f251c99e748362c1a035f2916efb9bb44fe5c5c3e857ea74ca06b3') }
    end
  end
end
