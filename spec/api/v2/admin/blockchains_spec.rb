# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Admin::Blockchains, type: :request do
  let(:admin) { create(:member, :admin, :level_3, email: 'example@gmail.com', uid: 'ID73BF61C8H0') }
  let(:token) { jwt_for(admin) }
  let(:level_3_member) { create(:member, :level_3) }
  let(:level_3_member_token) { jwt_for(level_3_member) }

  describe 'GET /api/v2/admin/blockchains/:id' do
    let(:blockchain) { Blockchain.find_by(key: "eth-rinkeby") }

    it 'returns information about specified blockchain' do
      api_get "/api/v2/admin/blockchains/#{blockchain.id}", token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.fetch('id')).to eq blockchain.id
      expect(result.fetch('name')).to eq blockchain.name
    end

    it 'returns error in case of invalid id' do
      api_get '/api/v2/admin/blockchains/120', token: token

      expect(response.code).to eq '404'
      expect(response).to include_api_error('record.not_found')
    end

    it 'return error in case of not permitted ability' do
      api_get "/api/v2/admin/blockchains/#{blockchain.id}", token: level_3_member_token
      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end
  end

  describe 'GET /api/v2/admin/blockchains' do
    it 'lists of blockchains' do
      api_get '/api/v2/admin/blockchains', token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.size).to eq 3
    end

    it 'returns paginated blockchains' do
      api_get '/api/v2/admin/blockchains', params: { limit: 2, page: 1 }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful

      expect(response.headers.fetch('Total')).to eq '3'
      expect(result.size).to eq 2
      expect(result.first['key']).to eq 'eth-kovan'

      api_get '/api/v2/admin/blockchains', params: { limit: 1, page: 2 }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful

      expect(response.headers.fetch('Total')).to eq '3'
      expect(result.size).to eq 1
      expect(result.first['key']).to eq 'eth-rinkeby'
    end

    it 'return error in case of not permitted ability' do
      api_get "/api/v2/admin/blockchains", token: level_3_member_token
      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end
  end

  describe 'POST /api/v2/admin/blockchains/new' do
    it 'creates new blockchain' do
      api_post '/api/v2/admin/blockchains/new', token: token, params: { key: 'test-blockchain', name: 'Test', client: 'test',server: 'http://127.0.0.1', height: 123333, explorer_transaction: 'test', explorer_address: 'test', status: 'active', min_confirmations: 6, step: 2 }
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['key']).to eq 'test-blockchain'
    end

    it 'validate step param' do
      api_post '/api/v2/admin/blockchains/new', token: token, params: { key: 'test-blockchain', name: 'Test', client: 'test',server: 'http://127.0.0.1', height: 123333, explorer_transaction: 'test', explorer_address: 'test', status: 'active', min_confirmations: 6, step: -2 }
      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.step.non_positive_step')
    end

    it 'validate min_confirmations param' do
      api_post '/api/v2/admin/blockchains/new', token: token, params: { key: 'test-blockchain', name: 'Test', client: 'test',server: 'http://127.0.0.1', height: 123333, explorer_transaction: 'test', explorer_address: 'test', status: 'active', min_confirmations: -6, step: 2 }
      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.min_confirmations.non_positive_min_confirmations')
    end

    it 'validate status param' do
      api_post '/api/v2/admin/blockchains/new', token: token, params: { key: 'test-blockchain', name: 'Test', client: 'test',server: 'http://127.0.0.1', height: 123333, explorer_transaction: 'test', explorer_address: 'test', status: 'actived', min_confirmations: 6, step: 2 }
      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.status.invalid_status')
    end

    it 'checked required params' do
      api_post '/api/v2/admin/blockchains/new', token: token, params: { }

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.blockchain.missing_key')
      expect(response).to include_api_error('admin.blockchain.missing_name')
      expect(response).to include_api_error('admin.blockchain.missing_client')
      expect(response).to include_api_error('admin.blockchain.missing_server')
      expect(response).to include_api_error('admin.blockchain.missing_height')
      expect(response).to include_api_error('admin.blockchain.missing_explorer_transaction')
      expect(response).to include_api_error('admin.blockchain.missing_explorer_address')
      expect(response).to include_api_error('admin.blockchain.missing_status')
      expect(response).to include_api_error('admin.blockchain.missing_min_confirmations')
      expect(response).to include_api_error('admin.blockchain.missing_step')
    end

    it 'return error in case of not permitted ability' do
      api_post '/api/v2/admin/blockchains/new', token: level_3_member_token, params: { key: 'test-blockchain', name: 'Test', client: 'test',server: 'http://127.0.0.1', height: 123333, explorer_transaction: 'test', explorer_address: 'test', status: 'active', min_confirmations: 6, step: 2 }
      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end
  end
end
