# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Account::Transactions, type: :request do
  let(:member) { create(:member, :level_3) }
  let(:other_member) { create(:member, :level_3) }
  let(:token) { jwt_for(member) }
  let(:level_0_member) { create(:member, :level_0) }
  let(:level_0_member_token) { jwt_for(level_0_member) }

  describe 'GET /api/v2/account/transactions' do
    before do
      create(:deposit_btc, member: member)
      create(:deposit_usd, member: member)
      create(:deposit_usd, member: member, txid: 1, amount: 520)
      create(:deposit_btc, member: member, created_at: 2.day.ago, txid: 'test', amount: 111)
      create(:deposit_usd, member: other_member, txid: 10)
      create(:btc_withdraw, member: member)
      create(:usd_withdraw, member: member)
    end

    it 'requires authentication' do
      api_get '/api/v2/account/transactions'
      expect(response.code).to eq '401'
    end

    it 'returns with auth token transactions' do
      api_get '/api/v2/account/transactions', token: token
      expect(response).to be_success
    end

    it 'returns all transactions num' do
      api_get '/api/v2/account/transactions', token: token

      result = JSON.parse(response.body)

      expect(result.size).to eq 6
    end

    it 'returns transactions for currency usd' do
      api_get '/api/v2/account/transactions', params: { currency: 'usd' }, token: token
      result = JSON.parse(response.body)

      expect(result.size).to eq 3
      expect(result.all? { |d| d['currency'] == 'usd' }).to be_truthy
    end

    it 'returns transactions for currency btc' do
      api_get '/api/v2/account/transactions', params: { currency: 'btc' }, token: token
      result = JSON.parse(response.body)

      expect(result.size).to eq 3
      expect(result.all? { |d| d['currency'] == 'btc' }).to be_truthy
    end

    it 'denies access to unverified member' do
      api_get '/api/v2/account/transactions', token: level_0_member_token
      expect(response.code).to eq '403'
      expect(response).to include_api_error('account.deposit.not_permitted')
    end
  end

end
