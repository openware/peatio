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

  describe 'list of wallets' do
    def request
      post_json '/management_api/v1/wallets', multisig_jwt_management_api_v1({}, *signers)
    end

    let(:signers) { %i[alex jeff]}
    let(:expected_response) { Wallet.all }

    it 'returns wallets' do
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
    let(:expected_response) { Wallet.find_by!(id: data[:id])}

    it 'returns wallet' do
      request
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)['id']).to eq(expected_response[:id])
    end

    it 'validates id' do
      data.delete(:id)
      request
      expect(response.body).to match(/id is missing/i)
      data[:id] = -1
      request
      expect(response.body).to match(/id does not have a valid value/i)
    end
  end

  describe 'create new wallet with expected attributes' do
    def request
      post_json '/management_api/v1/wallet/new', multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    let :data do
    { currency_id:    'btc',
      blockchain_key: 'btc-testnet',
      name:           'Btc Deposit Wallet',
      address:        'yVcZM6oUjfwrREm2CDb9G8BMHwwm5o5UsL',
      max_balance:    0.0,
      kind:           'hot',
      nsig:           1,
      parent:         nil,
      gateway:        'bitcoind',
      settings:       {} }
    end
    let(:signers) { %i[alex jeff] }

    it 'creates new wallet with state active' do
      request
      expect(response).to have_http_status(201)
      record = Wallet.find_by!(id: JSON.parse(response.body).fetch('id'))
      data.each do |key, value|
        expect(record[key]).to eq(value)
      end
    end

    it 'validates blockchain key' do
      data.delete(:blockchain_key)
      request
      expect(response.body).to match(/blockchain_key is missing/i)
      data[:blockchain_key] = 'foo'
      request
      expect(response.body).to match(/blockchain_key does not have a valid value/i)
    end

    it 'validates currency id' do
      data.delete(:currency_id)
      request
      expect(response.body).to match(/currency_id is missing/i)
      data[:currency_id] = 'foo'
      request
      expect(response.body).to match(/currency_id does not have a valid value/i)
    end

    it 'validates gateway' do
      data.delete(:gateway)
      request
      expect(response.body).to match(/gateway is missing/i)
      data[:gateway] = 'foo'
      request
      expect(response.body).to match(/gateway does not have a valid value/i)
    end

    it 'validates kind' do
      data.delete(:kind)
      request
      expect(response.body).to match(/kind is missing/i)
      data[:kind] = 'foo'
      request
      expect(response.body).to match(/kind does not have a valid value/i)
    end
  end

  describe 'update exist wallet' do
    def request
      put_json '/management_api/v1/wallet/update', multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    let :data do
      { id: 1,
        name: 'Foo Deposit Wallet' }
    end
    let(:signers) { %i[alex jeff] }

    it 'updates wallet' do
      request
      expect(response).to have_http_status(200)
      record = Wallet.find_by!(id: JSON.parse(response.body).fetch('id'))
      data.each do |key, value|
        expect(record[key]).to eq(value)
      end
    end
  end
end
