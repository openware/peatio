# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Admin::Markets, type: :request do
  let(:admin) { create(:member, :admin, :level_3, email: 'example@gmail.com', uid: 'ID73BF61C8H0') }
  let(:token) { jwt_for(admin) }
  let(:level_3_member) { create(:member, :level_3) }
  let(:level_3_member_token) { jwt_for(level_3_member) }

  describe 'GET /api/v2/admin/markets/:id' do
    let(:market) { Market.find_by(id: 'btcusd') }

    it 'returns information about specified market' do
      api_get "/api/v2/admin/markets/#{market.id}", token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.fetch('id')).to eq market.id
      expect(result.fetch('ask_unit')).to eq market.ask_unit
      expect(result.fetch('bid_unit')).to eq market.bid_unit
    end

    it 'returns error in case of invalid id' do
      api_get '/api/v2/admin/markets/120', token: token

      expect(response.code).to eq '404'
      expect(response).to include_api_error('record.not_found')
    end

    it 'return error in case of not permitted ability' do
      api_get "/api/v2/admin/markets/#{market.id}", token: level_3_member_token
      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end
  end

  describe 'GET /api/v2/admin/markets' do
    it 'lists of markets' do
      api_get '/api/v2/admin/markets', token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.size).to eq 2
    end

    it 'returns markets by ascending order' do
      api_get '/api/v2/admin/markets', params: { order_by: 'asc', sort_field: 'bid_unit'}, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result.first['bid_unit']).to eq 'eth'
    end

    it 'returns paginated markets' do
      api_get '/api/v2/admin/markets', params: { limit: 1, page: 1 }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful

      expect(response.headers.fetch('Total')).to eq '2'
      expect(result.size).to eq 1
      expect(result.first['id']).to eq 'btceth'

      api_get '/api/v2/admin/markets', params: { limit: 1, page: 2 }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful

      expect(response.headers.fetch('Total')).to eq '2'
      expect(result.size).to eq 1
      expect(result.first['id']).to eq 'btcusd'
    end

    it 'return error in case of not permitted ability' do
      api_get "/api/v2/admin/markets", token: level_3_member_token
      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end
  end

  describe 'POST /api/v2/admin/markets/new' do
    it 'creates new market' do
      api_post '/api/v2/admin/markets/new', params: { ask_unit: 'trst', bid_unit: 'btc' }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['id']).to eq 'trstbtc'
    end

    it 'validate ask_unit param' do
      api_post '/api/v2/admin/markets/new', params: { ask_unit: 'test', bid_unit: 'btc' }, token: token
      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.market.currency_doesnt_exist')
    end

    it 'validate bid_unit param' do
      api_post '/api/v2/admin/markets/new', params: { ask_unit: 'trst', bid_unit: 'test' }, token: token
      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.market.currency_doesnt_exist')
    end

    it 'validate enabled param' do
      api_post '/api/v2/admin/markets/new', params: { ask_unit: 'trst', bid_unit: 'btc', enabled: '123'}, token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.market.non_boolean_enabled')
    end

    it 'checked required params' do
      api_post '/api/v2/admin/markets/new',params: { }, token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.market.missing_ask_unit')
      expect(response).to include_api_error('admin.market.missing_bid_unit')
    end

    it 'return error in case of not permitted ability' do
      api_post '/api/v2/admin/markets/new', params: { ask_unit: 'trst', bid_unit: 'btc' }, token: level_3_member_token
      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end
  end

  describe 'POST /api/v2/admin/markets/update' do
    it 'update market' do
      api_post '/api/v2/admin/markets/update', params: { id: Market.first.id, bid_fee: 0.4 }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['bid_fee']).to eq '0.4'
    end

    it 'checked required params' do
      api_post '/api/v2/admin/markets/update', params: { }, token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.market.missing_id')
    end

    it 'return error in case of not permitted ability' do
      api_post '/api/v2/admin/markets/update', params: { id: Market.first.id, enabled: false }, token: level_3_member_token

      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end
  end
end
