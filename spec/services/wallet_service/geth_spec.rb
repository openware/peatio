# encoding: UTF-8
# frozen_string_literal: true

describe WalletService::Geth do

  around do |example|
    WebMock.disable_net_connect!
    example.run
    WebMock.allow_net_connect!
  end

  let(:deposit) { Deposit.find_by(currency: :eth) }
  let(:withdraw) { create(:eth_withdraw) }
  let(:deposit_wallet) { Wallet.find_by(currency: :eth, kind: :deposit) }
  let(:hot_wallet) { Wallet.find_by(currency: :eth, kind: :hot) }
  let(:eth_options) { { gas_limit: 21_000, gas_price: 10_000_000_000 } }

  describe '#create_address' do
    subject { WalletService[deposit_wallet].create_address }

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
      stub_request(:post, deposit_wallet.uri ).with(body: request_body).to_return(body: response_body)
    end

    it { is_expected.to eq(address: '0x42eb768f2244c8811c63729a21a3569731535f06', secret: 'pass@word') }
  end

  describe '#collect_deposit!' do
    context 'ETH collect deposit' do
      let(:deposit) { Deposit.find_by(currency: :eth) }
      let(:eth_payment_address) { deposit.account.payment_address }

      let(:issuer) { { address: eth_payment_address.address, secret: eth_payment_address.secret } }
      let(:recipient) { { address: hot_wallet.address } }

      let!(:payment_address) do
        create(:eth_payment_address, {account: deposit.account, address: '0xe3cb6897d83691a8eb8458140a1941ce1d6e6daa'})
      end

      let :request_body do
        { jsonrpc: '2.0',
          id:      1,
          method:  'eth_sendTransaction',
          params:  [{
                        from:  issuer[:address],
                        to:    recipient[:address],
                        value: '0x' + (deposit.amount_to_base_unit! - eth_options[:gas_limit] * eth_options[:gas_price]).to_s(16),
                        gas:   '0x' + eth_options[:gas_limit].to_s(16),
                        gasPrice: '0x' + eth_options[:gas_price].to_s(16)
                    }]
        }.to_json
      end

      let :response_body do
        { jsonrpc: '2.0',
          id:      1,
          result:  '0xc6ef2fc5426d6ad6fd9e2a26abeab0aa2411b7ab17f30a99d3cb96aed1d1055b'
        }.to_json
      end

      subject { WalletService[deposit_wallet].collect_deposit!(deposit) }

      before do
        WalletClient[deposit_wallet].class.any_instance.expects(:permit_transaction)
        stub_request(:post, deposit_wallet.uri).with(body: request_body).to_return(body: response_body)
      end

      it do
        is_expected.to eq('0xc6ef2fc5426d6ad6fd9e2a26abeab0aa2411b7ab17f30a99d3cb96aed1d1055b')
      end
    end

    context 'TRST collect deposit' do
      let(:deposit) { create(:new_deposit_trst, amount: 10) }
      let(:trst_payment_address) { deposit.account.payment_address }

      let(:deposit_wallet) { Wallet.find_by(currency: :trst, kind: :deposit) }
      let(:hot_wallet) { Wallet.find_by(currency: :trst, kind: :hot) }

      let(:issuer) { { address: trst_payment_address.address, secret: trst_payment_address.secret } }
      let(:recipient) { { address: hot_wallet.address } }

      let!(:payment_address) do
        create(:trst_payment_address, {account: deposit.account, address: '0xe3cb6897d83691a8eb8458140a1941ce1d6e6daa'})
      end

      let :request_body do
        { jsonrpc: '2.0',
          id:      1,
          method:  'eth_sendTransaction',
          params:  [{
                        from:  issuer[:address],
                        to:    '0x87099add3bcc0821b5b151307c147215f839a110',
                        data: '0xa9059cbb00000000000000002490488044995413388158458057986343121403466167320000000000000000000000000000000000000000000000000000000000989680'
                    }]
        }.to_json
      end

      let :response_body do
        { jsonrpc: '2.0',
          id:      1,
          result:  '0xc6ef2fc5426d6ad6fd9e2a26abeab0aa2411b7ab17f30a99d3cb96aed1d1055b'
        }.to_json
      end

      subject { WalletService[deposit_wallet].collect_deposit!(deposit) }

      before do
        WalletClient[deposit_wallet].class.any_instance.expects(:permit_transaction)
        stub_request(:post, deposit_wallet.uri).with(body: request_body).to_return(body: response_body)
      end

      it do
        is_expected.to eq('0xc6ef2fc5426d6ad6fd9e2a26abeab0aa2411b7ab17f30a99d3cb96aed1d1055b')
      end
    end
  end

  describe 'create_withdrawal!' do
    let(:issuer) { { address: hot_wallet.address, secret: hot_wallet.secret } }
    let(:recipient) { { address: withdraw.rid } }

    context 'ETH Withdrawal' do
      let(:withdraw) { create(:eth_withdraw, rid: '0x85h43d8a49eeb85d32cf465507dd71d507100c1') }

      let :request_body do
        { jsonrpc: '2.0',
          id:      1,
          method:  'eth_sendTransaction',
          params:  [{
                        from:  issuer[:address],
                        to:    recipient[:address],
                        value: '0x8a6e51a672858000'
                    }]
        }.to_json
      end

      let :response_body do
        { jsonrpc: '2.0',
          id:      1,
          result:  '0xc6ef2fc5426d6ad6fd9e2a26abeab0aa2411b7ab17f30a99d3cb96aed1d1055b'
        }.to_json
      end

      subject { WalletService[hot_wallet].build_withdrawal!(withdraw)}

      before do
        WalletClient[hot_wallet].class.any_instance.expects(:permit_transaction)
        stub_request(:post, 'http://127.0.0.1:8545/').with(body: request_body).to_return(body: response_body)
      end

      it { is_expected.to eq('0xc6ef2fc5426d6ad6fd9e2a26abeab0aa2411b7ab17f30a99d3cb96aed1d1055b') }
    end

    context 'TRST Withdrawal' do
      let(:withdraw) { create(:trst_withdraw, rid: '0x85h43d8a49eeb85d32cf465507dd71d507100c1') }
      let(:hot_wallet) { Wallet.find_by(currency: :trst, kind: :hot) }

      let :request_body do
        { jsonrpc: '2.0',
          id:      1,
          method:  'eth_sendTransaction',
          params:  [{
                        from:  issuer[:address],
                        to:    '0x87099add3bcc0821b5b151307c147215f839a110',
                        data: '0xa9059cbb000000000000000000000000085h43d8a49eeb85d32cf465507dd71d507100c100000000000000000000000000000000000000000000000000000000009834d8'
                    }]
        }.to_json
      end

      let :response_body do
        { jsonrpc: '2.0',
          id:      1,
          result:  '0xc6ef2fc5426d6ad6fd9e2a26abeab0aa2411b7ab17f30a99d3cb96aed1d1055b'
        }.to_json
      end

      subject { WalletService[hot_wallet].build_withdrawal!(withdraw)}

      before do
        WalletClient[hot_wallet].class.any_instance.expects(:permit_transaction)
        stub_request(:post, 'http://127.0.0.1:8545/').with(body: request_body).to_return(body: response_body)
      end

      it { is_expected.to eq('0xc6ef2fc5426d6ad6fd9e2a26abeab0aa2411b7ab17f30a99d3cb96aed1d1055b') }
    end
  end

  describe 'deposit_collection_fees!' do
    let(:deposit) { Deposit.find_by(currency: :trst) }
    let(:trst_payment_address) { deposit.account.payment_address }

    let(:issuer) { { address: hot_wallet.address, secret: hot_wallet.secret } }
    let(:recipient) { { address: trst_payment_address.address } }

    let!(:payment_address) do
      create(:trst_payment_address, {account: deposit.account, address: '0xe3cb6897d83691a8eb8458140a1941ce1d6e6daa'})
    end

    let :request_body do
      { jsonrpc: '2.0',
        id:      1,
        method:  'eth_sendTransaction',
        params:  [{
                      from:  issuer[:address],
                      to:    recipient[:address],
                      value: '0x38d7ea4c68000',
                      gas:   '0x' + eth_options[:gas_limit].to_s(16),
                      gasPrice: '0x' + eth_options[:gas_price].to_s(16)
                  }]
      }.to_json
    end

    let :response_body do
      { jsonrpc: '2.0',
        id:      1,
        result:  '0xc6ef2fc5426d6ad6fd9e2a26abeab0aa2411b7ab17f30a99d3cb96aed1d1055b'
      }.to_json
    end

    subject { WalletService[deposit_wallet].deposit_collection_fees(deposit) }

    before do
      WalletClient[deposit_wallet].class.any_instance.expects(:permit_transaction)
      stub_request(:post, deposit_wallet.uri).with(body: request_body).to_return(body: response_body)
    end

    it do
      is_expected.to eq('0xc6ef2fc5426d6ad6fd9e2a26abeab0aa2411b7ab17f30a99d3cb96aed1d1055b')
    end
  end
end