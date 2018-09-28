# encoding: UTF-8
# frozen_string_literal: true

describe WalletService::Bitcoincashd do

  around do |example|
    WebMock.disable_net_connect!
    example.run
    WebMock.allow_net_connect!
  end

  describe 'WalletService::Bitcoincashd' do

    let(:deposit) { Deposit.find_by(currency: :bch) }
    let(:withdraw) { create(:bch_withdraw) }
    let(:deposit_wallet) { Wallet.find_by(gateway: :bitcoincashd, kind: :deposit) }
    let(:hot_wallet) { Wallet.find_by(gateway: :bitcoincashd, kind: :hot) }

    context '#create_address' do
      subject { WalletService[deposit_wallet].create_address }

      let :request_body do
        { jsonrpc: '1.0',
          method: 'getnewaddress',
          params: []
        }.to_json
      end

      let :response_body do
        { result: 'bchtest:pzsze7ety982w764sh9nq2ztknz0988w9cp7sv0zpj' }.to_json
      end

      before do
        stub_request(:post, deposit_wallet.uri).with(body: request_body).to_return(body: response_body)
      end

      it { is_expected.to eq(address: 'bchtest:pzsze7ety982w764sh9nq2ztknz0988w9cp7sv0zpj') }
    end

    context '#collect_deposit!' do
      subject { WalletService[deposit_wallet].collect_deposit!(deposit) }

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
        stub_request(:post, deposit_wallet.uri).with(body: request_body).to_return(body: response_body)
      end

      it { is_expected.to eq('dcedf50780f251c99e748362c1a035f2916efb9bb44fe5c5c3e857ea74ca06b3') }
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
