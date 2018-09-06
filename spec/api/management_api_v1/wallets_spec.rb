# encoding: UTF-8
# frozen_string_literal: true

describe ManagementAPIv1::Wallets, type: :request do
  before do
    defaults_for_management_api_v1_security_configuration!
    management_api_v1_security_configuration.merge! \
      scopes: {
      read_wallets:  { permitted_signers: %i[alex jeff], mandatory_signers: %i[alex] },
      write_wallets: { permitted_signers: %i[alex jeff], mandatory_signers: %i[alex] }
    }
  end

  describe 'List of wallets' do
    def request
      post_json '/management_api/v1/wallets', multisig_jwt_management_api_v1({}, *signers)
    end
    let(:signers) { %i[alex jeff]}
    let(:expected_response) { Wallet.all }
    it 'Returns wallets' do
      request
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body).map { |x| x.fetch('id') }).to eq(expected_response.map { |x| x[:id] })
    end
  end

  describe 'Return wallet by id' do
    def request
      post_json '/management_api/v1/wallet/get', multisig_jwt_management_api_v1({ data: data }, *signers)
    end
    let(:data) { { id: 1 } }
    let(:signers) { %i[alex jeff] }
    let(:expected_response) { Wallet.find(data[:id])}
    it 'Return wallet' do
      request
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)['id']).to eq(expected_response[:id])
    end
  end

  describe 'Create new wallet' do
    def request
      post_json '/management_api/v1/wallet/new', multisig_jwt_management_api_v1({ data: data }, *signers)
    end
    let(:data) { { id: Wallet.last.id + 1, currency_id: 'btc', blockchain_key: 'btc-testnet',
                   name: 'Btc Deposit Wallet', address: 'yVcZM6oUjfwrREm2CDb9G8BMHwwm5o5UsL', 
                   max_balance: 0.0, kind: 'hot', nsig: 1, parent: nil,
                   gateway: 'geth', settings: ''} }
    let(:signers) { %i[alex jeff] }
    let(:expected_response) { Wallet.find(data[:id])}
    it 'Create new wallet' do
      request
      expect(response).to have_http_status(201)
      expect(JSON.parse(response.body)['id']).to eq(expected_response[:id])
    end
  end

  describe 'Update wallet' do
    def request
      put_json '/management_api/v1/wallet/update', multisig_jwt_management_api_v1({ data: data }, *signers)
    end
    let(:data) { { id: 1, name: 'Foo Deposit Wallet' } }
    let(:signers) { %i[alex jeff] }
    let(:expected_response) { Wallet.find(data[:id]).update('name': 'Foo Deposit Wallet')}
    it 'Update' do
      request
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)['name']).to eq(data[:name].to_s)
    end
  end
end
