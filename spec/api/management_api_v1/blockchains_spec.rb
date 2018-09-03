# encoding: UTF-8
# frozen_string_literal: true

describe ManagementAPIv1::Blockchains, type: :request do
  before do
    defaults_for_management_api_v1_security_configuration!
    management_api_v1_security_configuration.merge! \
      scopes: {
        read_blockchains:  { permitted_signers: %i[alex jeff], mandatory_signers: %i[alex] },
        write_blockchains: { permitted_signers: %i[alex jeff], mandatory_signers: %i[alex] }
    }
  end

  describe 'list of blockchains' do
    def request
      post_json '/management_api/v1/blockchains', multisig_jwt_management_api_v1({}, *signers)
    end

    let(:signers) { %i[alex jeff]}
    let(:expected_response) { Blockchain.all }

    it 'returns blockchains' do
      request
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body).map { |x| x.fetch('key') }).to eq(expected_response.map { |x| x[:key] })
    end
  end

  describe 'return blockchain by key' do
    def request
      post_json '/management_api/v1/blockchains/get', multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    let(:data) { { key: 'eth-rinkeby' } }
    let(:signers) { %i[alex jeff] }
    let(:expected_response) { Blockchain.find_by!(key: data[:key])}

    it 'returns blockchain by key' do
      request
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)['key']).to eq(expected_response[:key])
    end

    it 'validates key' do
      data.delete(:key)
      request
      expect(response.body).to match(/key is missing/i)
      data[:key] = 'btc1'
      request
      expect(response.body).to match(/key does not have a valid value/i)
    end
  end

  describe 'create new blockchain with expected attributes' do
    def request
      post_json '/management_api/v1/blockchains/new', multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    let :data do
    {  key:                   'xrp-testnet1',
       name:                  'Ripple Testnet',
       client:                'ripple',
       server:                'http://user:password@127.0.0.1:5005',
       height:                11773777,
       explorer_address:      'https://bithomp.com/explorer/\#{address}',
       explorer_transaction:  'https://bithomp.com/explorer/\#{txid}',
       min_confirmations:     6,
       status:                'active' }
    end
    let(:signers) { %i[alex jeff] }

    it 'creates new blockchain with expected attributes' do
      request
      expect(response).to have_http_status(201)
      record = Blockchain.find_by!(key: JSON.parse(response.body).fetch('key'))
      data.each do |key, value|
        expect(record[key]).to eq(value)
      end
    end

    it 'validates client' do
      data.delete(:client)
      request
      expect(response.body).to match(/client is missing/i)
      data[:client] = 'foo'
      request
      expect(response.body).to match(/client does not have a valid value/i)
    end

    it 'validates height' do
      data.delete(:height)
      request
      expect(response.body).to match(/height is missing/i)
      data[:height] = -1
      request
      expect(response.body).to match(/height must be greater than zero./i)
    end
  end

  describe 'update blockchain' do
    def request
      put_json '/management_api/v1/blockchains/update', multisig_jwt_management_api_v1({ data: data }, *signers)
    end
    let :data do
      { key:                'xrp-testnet',
        min_confirmations:  5,
        height:             11111111}
    end
    let(:signers) { %i[alex jeff] }

    it 'updates blockchain' do
      request
      expect(response).to have_http_status(200)
      record = Blockchain.find_by!(key: JSON.parse(response.body).fetch('key'))
      data.each do |key, value|
        expect(record[key]).to eq(value)
      end
    end

    it 'validates read-only attributes' do
      request
      record = Blockchain.find_by!(key: data[:key])
      expect(record[:client]).to eq('ripple')
      data[:client] = 'bitcoin'
      request
      record = Blockchain.find_by!(key: data[:key])
      expect(record[:client]).to eq('ripple')
    end
  end
end
