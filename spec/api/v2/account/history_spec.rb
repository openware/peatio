# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Account::History, type: :request do
  let(:member) { create(:member, :level_3) }
  let(:other_member) { create(:member, :level_3) }
  let(:token) { jwt_for(member) }
  let(:level_0_member) { create(:member, :level_0) }
  let(:level_0_member_token) { jwt_for(level_0_member) }
  let(:deposit) { create(:deposit_btc, member: member) }
  let(:withdraw) { create(:btc_withdraw, member: member) }

  describe 'GET /api/v2/account/history' do
    before do
      create(:liability_history, member_id: member.id, operation_date: 3.days.ago, operation_type: 'Trade', currency_id: 'eth')
      create(:liability_history, member_id: member.id, operation_date: 2.days.ago, operation_type: 'Deposit', operation_id: deposit.id, currency_id: 'btc')
      create(:liability_history, member_id: member.id, operation_date: 1.days.ago, operation_type: 'Withdraw', operation_id: withdraw.id, currency_id: 'btc')

      create(:liability_history, operation_type: 'Trade')
      create(:liability_history, operation_type: 'Deposit')
      create(:liability_history, operation_type: 'Withdraw')
    end

    it 'requires authentication' do
      api_get '/api/v2/account/history'
      expect(response.code).to eq '401'
    end

    it 'returns history with auth token' do
      api_get '/api/v2/account/history', token: token
      expect(response).to be_successful
    end

    it 'returns history with valid params' do
      api_get '/api/v2/account/history', params: { filter: 'deposit+withdraw', sort: 'operation_date', order_by: 'asc', limit: 10 }, token: token
      expect(response).to be_successful
    end

    it 'returns error with invalid filter param' do
      api_get '/api/v2/account/history', params: { filter: 'test' }, token: token
      expect(response.code).to eq '422'
      expect(response).to include_api_error('account.history.filter_invalid')
    end

    it 'returns error with invalid sort param' do
      api_get '/api/v2/account/history', params: { sort: 'test' }, token: token
      expect(response.code).to eq '422'
      expect(response).to include_api_error('account.history.sort_invalid')
    end

    it 'returns error with invalid order param' do
      api_get '/api/v2/account/history', params: { sort: 'operation_date', order_by: 'test' }, token: token
      expect(response.code).to eq '422'
      expect(response).to include_api_error('account.history.order_by_invalid')
    end

    it 'returns error with invalid limit param' do
      api_get '/api/v2/account/history', params: { limit: 'test' }, token: token
      expect(response.code).to eq '422'
      expect(response).to include_api_error('account.history.non_integer_limit')
    end

    it 'returns all history for current user' do
      api_get '/api/v2/account/history', token: token
      result = JSON.parse(response.body)
      expect(result.count).to eq 3
    end

    it 'returns all history for current user in desc order by date by default' do
      api_get '/api/v2/account/history', token: token
      result = JSON.parse(response.body)
      date_array = result.map{|r| r['created_at']}
      expect(date_array).to eq(date_array.sort.reverse)
    end

    it 'sorts asc by operation_date' do
      api_get '/api/v2/account/history', params: { sort: 'operation_date', order_by: 'asc' }, token: token
      result = JSON.parse(response.body)
      date_array = result.map{|r| r['created_at']}
      expect(date_array).to eq(date_array.sort)
    end

    it 'returns only trades if filter=trade' do
      api_get '/api/v2/account/history', params: { filter: 'trade' }, token: token
      result = JSON.parse(response.body)
      expect(result.count).to eq 1
      expect(result.first['type']).to eq('trade')
    end

    it 'returns only deposit and withdraw if filter=deposit+withdraw' do
      api_get '/api/v2/account/history', params: { filter: 'deposit+withdraw' }, token: token
      result = JSON.parse(response.body)
      expect(result.count).to eq 2
      expect(result.map{|r| r['type']}).to match_array(['deposit', 'withdraw'])
    end

    it 'returns limited history' do
      api_get '/api/v2/account/history', params: { limit: 2 }, token: token
      result = JSON.parse(response.body)
      expect(result.count).to eq 2
    end

    it 'paginates history' do
      api_get '/api/v2/account/history', params: { limit: 2, page: 2 }, token: token
      result = JSON.parse(response.body)
      expect(result.count).to eq 1
      expect(response.headers.fetch('Total')).to eq '3'
    end

    it 'denies access to unverified member' do
      api_get '/api/v2/account/history', token: level_0_member_token
      expect(response.code).to eq '403'
      expect(response).to include_api_error('account.deposit.not_permitted')
    end

    it 'returns error if date is invalid' do
      api_get '/api/v2/account/history', params: { time_from: '12/13/2012' }, token: token
      expect(response.code).to eq '422'
      expect(response).to include_api_error('account.history.non_integer_time_from')
    end

    it 'returns operations in date range' do
      api_get '/api/v2/account/history', params: { time_from: (2.days.ago - 2.hours).to_i, time_to: Time.now.to_i }, token: token
      result = JSON.parse(response.body)
      expect(result.count).to eq 2
    end

    it 'returns operations with given currency' do
      api_get '/api/v2/account/history', params: { currency: 'eth' }, token: token
      result = JSON.parse(response.body)
      expect(result.count).to eq 1
      expect(result.first['currency']).to eq 'eth'
    end

  end
end
