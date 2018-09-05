# encoding: UTF-8
# frozen_string_literal: true

describe ManagementAPIv1::Deposits, type: :request do
  before do
    defaults_for_management_api_v1_security_configuration!
    management_api_v1_security_configuration.merge! \
      scopes: {
        read_blockchains:  { permitted_signers: %i[alex jeff], mandatory_signers: %i[alex] },
        write_blockchains: { permitted_signers: %i[alex jeff], mandatory_signers: %i[alex] }
    }
  end

  describe 'List Blockchains' do
    def request
      post_json '/management_api/v1/blockchains', multisig_jwt_management_api_v1({}, *signers)
    end

    let(:signers) { %i[alex jeff]}
    let(:expected_response) { Blockchain.all }

    it 'Returns blockchains' do
      request
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body).map { |x| x.fetch('key') }).to eq(expected_response.map { |x| x[:key] })
    end
  end
  describe 'Return blockchain by key.' do
    def request
      post_json '/management_api/v1/blockchains/get', multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    let(:data) { { key: 'eth-rinkeby' } }
    let(:signers) { %i[alex jeff] }
    let(:expected_response) { Blockchain.find_by(key: data[:key])}
    it 'Get blockchain' do
      request
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)['key']).to eq(expected_response[:key])
    end
  end

  describe 'Create new blockchain' do
    def request
      post_json '/management_api/v1/blockchains/new', multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    let(:data) { { key: "xrp-testnet1", name: "Ripple Testnet", client: "ripple", server: "http://user:password@127.0.0.1:5005", height: 11773777, explorer_address: "https://bithomp.com/explorer/\#{address}", explorer_transaction: "https://bithomp.com/explorer/\#{txid}", min_confirmations: 6, status: "active"} }
    let(:signers) { %i[alex jeff] }
    let(:expected_response) { Blockchain.find_by(key: data[:key])}

    it 'Create new market' do
      request
      expect(response).to have_http_status(201)
      expect(JSON.parse(response.body)['key']).to eq(expected_response[:key])
    end
  end

  describe 'Update blockchain' do
    def request
      put_json '/management_api/v1/blockchains/update', multisig_jwt_management_api_v1({ data: data }, *signers)
    end
    let(:data) { { key: 'xrp-testnet', name: 'Ripple mainnet' } }
    let(:signers) { %i[alex jeff] }
    let(:do) { Blockchain.find_by(key: data[:key]).update(name: 'Ripple mainnet') }
    let(:expected_response) { Blockchain.find_by(key: data[:key])}

    it 'Update' do
      request
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)['name']).to eq(expected_response[:name])
    end
  end
end
