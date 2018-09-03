# encoding: UTF-8
# frozen_string_literal: true

describe ManagementAPIv1::Markets, type: :request do
  before do
    defaults_for_management_api_v1_security_configuration!
    management_api_v1_security_configuration.merge! \
      scopes: {
        read_markets:  { permitted_signers: %i[alex jeff], mandatory_signers: %i[alex] },
        write_markets: { permitted_signers: %i[alex jeff], mandatory_signers: %i[alex] }
    }
  end

  describe 'list markets' do
    def request
      post_json '/management_api/v1/markets', multisig_jwt_management_api_v1({}, *signers)
    end

    let(:signers) { %i[alex jeff]}
    let(:expected_response) { Market.all }

    it 'returns markets' do
      request
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body).map { |x| x.fetch('id') }).to eq(expected_response.map { |x| x[:id] })
    end
  end

  describe 'return market by id' do
    def request
      post_json '/management_api/v1/markets/get', multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    let(:data) { { id: 'btcusd' } }
    let(:signers) { %i[alex jeff] }
    let(:expected_response) { Market.find_by!(id: data[:id])}

    it 'returns market' do
      request
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)['id']).to eq(expected_response[:id])
    end

    it 'validates key' do
      data.delete(:id)
      request
      expect(response.body).to match(/id is missing/i)
      data[:id] = 'btcusd1'
      request
      expect(response.body).to match(/couldn't find record/i)
    end
  end

  describe 'create new market' do
    def request
      post_json '/management_api/v1/markets/new', multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    let :data do
      { id:             'usdbtc',
        ask_unit:       'usd',
        bid_unit:       'btc',
        ask_fee:        0.001,
        bid_fee:        0.001,
        ask_precision:  8,
        bid_precision:  8,
        enabled:        true }
    end
    let(:signers) { %i[alex jeff] }

    it 'creates new market with expected attributes' do
      request
      expect(response).to have_http_status(201)
      record = Market.find_by!(id: JSON.parse(response.body).fetch('id'))
      data.each do |key, value|
        expect(record[key]).to eq(value)
      end
    end

    it 'validates ask unit' do
      data.delete(:ask_unit)
      request
      expect(response.body).to match(/ask_unit is missing/i)
      data[:ask_unit] = 'usd1'
      request
      expect(response.body).to match(/ask_unit does not have a valid value/i)
    end

    it 'validates bid unit' do
      data.delete(:bid_unit)
      request
      expect(response.body).to match(/bid_unit is missing/i)
      data[:bid_unit] = 'btc1'
      request
      expect(response.body).to match(/bid_unit does not have a valid value/i)
    end
  end

  describe 'update market' do
    def request
      put_json '/management_api/v1/markets/update', multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    let :data do
      { id: 'btcusd',
        ask_fee: 0.1 }
    end
    let(:signers) { %i[alex jeff] }

    it 'updates market' do
      request
      expect(response).to have_http_status(200)
      record = Market.find_by!(id: data[:id])
      data.each do |key, value|
        expect(record[key]).to eq(value)
      end
    end

    it 'validates read-only attributes' do
      request
      record = Market.find_by!(id: data[:id])
      expect(record[:ask_unit]).to eq('btc')
      data[:ask_unit] = 'eth'
      request
      record = Market.find_by!(id: data[:id])
      expect(record[:ask_unit]).to eq('btc')
    end
  end
end
