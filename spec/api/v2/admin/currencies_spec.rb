# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Admin::Currencies, type: :request do
  let(:admin) { create(:member, :admin, :level_3, email: 'example@gmail.com', uid: 'ID73BF61C8H0') }
  let(:token) { jwt_for(admin) }
  let(:level_3_member) { create(:member, :level_3) }
  let(:level_3_member_token) { jwt_for(level_3_member) }

  describe 'GET /api/v2/admin/currencies/:id' do
    let(:fiat) { Currency.find(:usd) }
    let(:coin) { Currency.find(:btc) }

    let(:expected_for_fiat) do
      %w[id symbol type deposit_fee withdraw_fee withdraw_limit_24h withdraw_limit_72h min_collection_amount base_factor precision position]
    end
    let(:expected_for_coin) do
      expected_for_fiat.concat(%w[blockchain_key explorer_transaction explorer_address options])
    end

    it 'returns information about specified currency' do
      api_get "/api/v2/admin/currencies/#{coin.id}", token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.fetch('id')).to eq coin.id
    end

    it 'returns correct keys for fiat' do
      api_get "/api/v2/admin/currencies/#{fiat.id}", token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)

      expected_for_fiat.each { |key| expect(result).to have_key key }

      (expected_for_coin - expected_for_fiat).each do |key|
        expect(result).not_to have_key key
      end
    end

    it 'returns correct keys for coin' do
      api_get "/api/v2/admin/currencies/#{coin.id}", token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expected_for_coin.each { |key| expect(result).to have_key key }
    end

    it 'returns error in case of invalid id' do
      api_get '/api/v2/admin/currencies/invalid', token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.currency.doesnt_exist')
    end

    it 'return error in case of not permitted ability' do
      api_get "/api/v2/admin/currencies/#{coin.id}", token: level_3_member_token
      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end
  end

  describe 'GET /api/v2/admin/currencies' do
    it 'list of currencies' do
      api_get '/api/v2/admin/currencies', token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.size).to eq Currency.count
    end

    it 'list of coins' do
      api_get '/api/v2/admin/currencies', params: { type: 'coin' }, token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.size).to eq Currency.coins.size
    end

    it 'list of fiats' do
      api_get '/api/v2/admin/currencies', params: { type: 'fiat' }, token: token
      expect(response).to be_successful

      result = JSON.parse(response.body, symbolize_names: true)
      expect(result.size).to eq Currency.fiats.size
      expect(result.dig(0, :id)).to eq 'eur'
    end

    it 'returns error in case of invalid type' do
      api_get '/api/v2/admin/currencies', params: { type: 'invalid' }, token: token
      expect(response).to have_http_status 422
    end

    it 'returns currencies by ascending order' do
      api_get '/api/v2/admin/currencies', params: { ordering: 'asc', order_by: 'id'}, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result.first['id']).to eq 'btc'
    end

    it 'returns paginated currencies' do
      api_get '/api/v2/admin/currencies', params: { limit: 3, page: 1 }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful

      expect(response.headers.fetch('Total')).to eq '6'
      expect(result.size).to eq 3
      expect(result.first['id']).to eq 'btc'

      api_get '/api/v2/admin/currencies', params: { limit: 3, page: 2 }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful

      expect(response.headers.fetch('Total')).to eq '6'
      expect(result.size).to eq 3
      expect(result.first['id']).to eq 'ring'
    end

    it 'return error in case of not permitted ability' do
      api_get '/api/v2/admin/currencies', token: level_3_member_token

      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end
  end

  describe 'POST /api/v2/admin/currencies/new' do
    it 'create coin' do
      api_post '/api/v2/admin/currencies/new', params: { id: 'test', symbol: 'T', blockchain_key: 'btc-testnet' }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['type']).to eq 'coin'
    end

    it 'create fiat' do
      api_post '/api/v2/admin/currencies/new', params: { id: 'test', symbol: 'T', type: 'fiat' }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['type']).to eq 'fiat'
    end

    it 'validate blockchain_key param' do
      api_post '/api/v2/admin/currencies/new', params: { id: 'test', symbol: 'T', blockchain_key: 'test-blockchain' }, token: token
      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.currency.blockchain_key_doesnt_exist')
    end

    it 'validate type param' do
      api_post '/api/v2/admin/currencies/new', params: { id: 'test', symbol: 'T', blockchain_key: 'test-blockchain' , type: 'test'}, token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.currency.invalid_type')
    end

    it 'validate enabled param' do
      api_post '/api/v2/admin/currencies/new', params: { id: 'test', symbol: 'T', type: 'fiat', enabled: '123'}, token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.currency.non_boolean_enabled')
    end

    it 'validate options param' do
      api_post '/api/v2/admin/currencies/new', params: { id: 'test', symbol: 'T', type: 'fiat', options: 'test'}, token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.currency.non_json_options')
    end

    it 'checked required params' do
      api_post '/api/v2/admin/currencies/new', params: { }, token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.currency.missing_id')
      expect(response).to include_api_error('admin.currency.missing_symbol')
      expect(response).to include_api_error('admin.currency.missing_blockchain_key')
    end

    it 'return error in case of not permitted ability' do
      api_post '/api/v2/admin/currencies/new', params: { id: 'test', symbol: 'T', blockchain_key: 'btc-testnet' }, token: level_3_member_token

      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end
  end

  describe 'POST /api/v2/admin/currencies/update' do
    it 'update fiat' do
      api_post '/api/v2/admin/currencies/update', params: { id: Currency.find_by(type: 'fiat').id, symbol: 'S' }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['symbol']).to eq 'S'
    end

    it 'update coin' do
      api_post '/api/v2/admin/currencies/update', params: { id: Currency.find_by(type: 'coin').id, symbol: 'S' }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['symbol']).to eq 'S'
    end

    it 'validate blockchain_key param' do
      api_post '/api/v2/admin/currencies/update', params: { id: Currency.find_by(type: 'coin').id, blockchain_key: 'test' }, token: token
      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.currency.blockchain_key_doesnt_exist')
    end

    it 'validate enabled param' do
      api_post '/api/v2/admin/currencies/update', params: { id: Currency.first.id, enabled: '123'}, token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.currency.non_boolean_enabled')
    end

    it 'validate options param' do
      api_post '/api/v2/admin/currencies/update', params: { id: Currency.first.id, options: 'test'}, token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.currency.non_json_options')
    end

    it 'checked required params' do
      api_post '/api/v2/admin/currencies/update', params: { }, token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.currency.missing_id')
    end

    it 'return error in case of not permitted ability' do
      api_post '/api/v2/admin/currencies/update', params: { id: Currency.first.id, symbol: 'T' }, token: level_3_member_token

      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end
  end
end
