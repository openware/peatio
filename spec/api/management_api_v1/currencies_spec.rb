# encoding: UTF-8
# frozen_string_literal: true

describe ManagementAPIv1::Currencies, type: :request do
  before do
    defaults_for_management_api_v1_security_configuration!
    management_api_v1_security_configuration.merge! \
      scopes: {
      read_currencies:  { permitted_signers: %i[alex jeff], mandatory_signers: %i[alex] },
      write_currencies: { permitted_signers: %i[alex jeff], mandatory_signers: %i[alex] }
    }
  end

  describe 'list currencies' do
    def request
      post_json '/management_api/v1/currencies', multisig_jwt_management_api_v1({}, *signers)
    end
    let(:signers) { %i[alex jeff]}
    let(:expected_response) { Currency.all }

    it 'returns list of currencies' do
      request
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body).map { |x| x.fetch('id') }).to eq(expected_response.map { |x| x[:id] })
    end
  end

  describe 'get currency' do
    def success_request
      post_json '/management_api/v1/currency/get', multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    def failed_request
      post_json '/management_api/v1/currency/get', multisig_jwt_management_api_v1({ data: unexisting_data }, *signers)
    end  
    let(:unexisting_data) { { id: 'foo' } }
    let(:data) { { id: 'btc' } }
    let(:signers) { %i[alex jeff] }
    let(:expected_response) { Currency.find(data[:id])}
    
    it 'returns currency by id' do
      success_request
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)['type']).to eq(expected_response[:type])
    end


    it 'returns error in case of unexisting data' do
      failed_request
      expect(response).to have_http_status(404)
      expect(JSON.parse(response.body)).to eq ({"error" => "Couldn't find record."})
    end

    it 'validates key' do
      unexisting_data.delete(:id)
      failed_request
      expect(response.body).to match(/id is missing/i)
      unexisting_data[:id] = 'btc1'
      failed_request
      expect(response.body).to match(/couldn't find record/i)
    end
  end

  describe 'create new currency' do
    def request
      post_json '/management_api/v1/currency/new', multisig_jwt_management_api_v1({ data: data }, *signers)
    end
    let(:data) { { id: 'foo', 
                   blockchain_key: 'btc-testnet', 
                   symbol: '$',
                   type: 'coin',
                   deposit_fee: 0.0,
                   quick_withdraw_limit: 0.1,
                   withdraw_fee: 0.0,
                   base_factor: 100000000,
                   precision: 8,
                   enabled: true } }
    let(:signers) { %i[alex jeff] }
    
    it 'returns new market with enabled state' do
      request
      expect(response).to have_http_status(201)
      record = Currency.find_by!(id: JSON.parse(response.body).fetch('id'))
      data.each do |key, value|
        expect(record[key]).to eq(value)
      end
    end

    it 'validates blockchain key' do
      data.delete(:blockchain_key)
      request
      expect(response.body).to match(/blockchain_key is missing/i)
      data[:blockchain_key] = 'btc-mainet'
      request
      expect(response.body).to match(/blockchain_key does not have a valid value/i)
    end

    it 'validates type' do
      data.delete(:type)
      request
      expect(response.body).to match(/type is missing/i)
      data[:type] = 'foo'
      request
      expect(response.body).to match(/Type is not included in the list/i)
    end
  end

  describe 'update currency' do
    def request
      put_json '/management_api/v1/currency/update', multisig_jwt_management_api_v1({ data: data }, *signers)
    end
    let(:data) { { id: 'btc', symbol: '$' } }
    let(:signers) { %i[alex jeff] }

    it 'returns updated currency' do
      request
      expect(response).to have_http_status(200)
      record = Currency.find_by!(id: data[:id])
      data.each do |key, value|
        expect(record[key]).to eq(value)
      end
    end
  end
end
