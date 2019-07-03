# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Admin::Withdraws, type: :request do
  let(:admin) { create(:member, :admin, :level_3, email: 'example@gmail.com', uid: 'ID73BF61C8H0') }
  let(:token) { jwt_for(admin) }
  let(:level_3_member) { create(:member, :level_3) }
  let(:level_3_member_token) { jwt_for(level_3_member) }
  let!(:fiat_withdraws) do
    [
      create(:usd_withdraw, amount: 10.0, sum: 10.0),
      create(:usd_withdraw, amount: 9.0, sum: 9.0),
      create(:usd_withdraw, amount: 100.0, sum: 100.0, member: level_3_member),
    ]
  end
  let!(:coin_withdraws) do
    [
      create(:btc_withdraw, amount: 42.0, sum: 42.0, txid: 'special_txid'),
      create(:btc_withdraw, amount: 11.0, sum: 11.0, member: level_3_member),
      create(:btc_withdraw, amount: 12.0, sum: 12.0, member: level_3_member),
    ]
  end

  describe 'GET /api/v2/admin/withdraws' do
    let(:url) { '/api/v2/admin/withdraws' }

    it 'get all withdraws' do
      api_get url, token: token

      actual = JSON.parse(response.body)
      expected = coin_withdraws + fiat_withdraws

      expect(actual.length).to eq expected.length
      expect(actual.map { |a| a['state'] }).to match_array expected.map(&:aasm_state)
      expect(actual.map { |a| a['id'] }).to match_array expected.map(&:id)
      expect(actual.map { |a| a['currency'] }).to match_array expected.map(&:currency_id)
      expect(actual.map { |a| a['member'] }).to match_array expected.map(&:member_id)
      expect(actual.map { |a| a['type'] }).to match_array(expected.map { |d| d.coin? ? 'coin' : 'fiat' })
    end

    context 'ordering' do
      it 'ascending by id' do
        api_get url, token: token, params: { order_by: 'id', ordering: 'asc' }

        actual = JSON.parse(response.body)
        expected = (coin_withdraws + fiat_withdraws).sort { |a, b| a.id <=> b.id }

        expect(actual.map { |a| a['id'] }).to eq expected.map(&:id)
      end

      it 'descending by sum' do
        api_get url, token: token, params: { order_by: 'sum', ordering: 'desc' }

        actual = JSON.parse(response.body)
        expected = (coin_withdraws + fiat_withdraws).sort { |a, b| b.sum <=> a.sum }

        expect(actual.map { |a| a['id'] }).to eq expected.map(&:id)
      end
    end

    context 'filtering' do
      it 'by member' do
        api_get url, token: token, params: { member: level_3_member.id }

        actual = JSON.parse(response.body)
        expected = (coin_withdraws + fiat_withdraws).select { |d| d.member_id == level_3_member.id }

        expect(actual.length).to eq expected.length
        expect(actual.map { |a| a['state'] }).to match_array expected.map(&:aasm_state)
        expect(actual.map { |a| a['id'] }).to match_array expected.map(&:id)
        expect(actual.map { |a| a['currency'] }).to match_array expected.map(&:currency_id)
        expect(actual.map { |a| a['member'] }).to all eq level_3_member.id
        expect(actual.map { |a| a['type'] }).to match_array(expected.map { |d| d.coin? ? 'coin' : 'fiat' })
      end

      it 'by type' do
        api_get url, token: token, params: { type: 'coin' }

        actual = JSON.parse(response.body)
        expected = coin_withdraws

        expect(actual.length).to eq expected.length
        expect(actual.map { |a| a['state'] }).to match_array expected.map(&:aasm_state)
        expect(actual.map { |a| a['id'] }).to match_array expected.map(&:id)
        expect(actual.map { |a| a['currency'] }).to match_array expected.map(&:currency_id)
        expect(actual.map { |a| a['member'] }).to match_array expected.map(&:member_id)
        expect(actual.map { |a| a['type'] }).to all eq 'coin'
      end

      it 'by txid' do
        api_get url, token: token, params: { txid: coin_withdraws.first.txid }

        actual = JSON.parse(response.body)
        expected = coin_withdraws.first

        expect(actual.length).to eq 1
        expect(actual.first['state']).to eq expected.aasm_state
        expect(actual.first['id']).to eq expected.id
        expect(actual.first['currency']).to eq expected.currency_id
        expect(actual.first['member']).to eq expected.member_id
        expect(actual.first['type']).to eq 'coin'
      end

      it 'with upper sum bound' do
        api_get url, token: token, params: { sum_to: 20 }

        actual = JSON.parse(response.body)
        expected = (coin_withdraws + fiat_withdraws).select { |d| d.sum <= 20 }

        expect(actual.length).to eq expected.length
        expect(actual.map { |a| a['id'] }).to match_array expected.map(&:id)
      end

      it 'with lower sum bound' do
        api_get url, token: token, params: { sum_from: 20 }

        actual = JSON.parse(response.body)
        expected = (coin_withdraws + fiat_withdraws).select { |d| d.sum >= 20 }

        expect(actual.length).to eq expected.length
        expect(actual.map { |a| a['id'] }).to match_array expected.map(&:id)
      end
    end
  end

  describe 'POST /api/v2/admin/withdraws/update' do
    let(:url) { '/api/v2/admin/withdraws/update' }
    let(:fiat) { fiat_withdraws.first }
    let(:coin) { coin_withdraws.first }

    context 'validates params' do
      it 'does not pass unsupported action' do
        api_post url, token: token, params: { action: 'illegal', id: fiat.id }

        expect(response.status).to eq 422
        expect(response).to include_api_error('admin.withdraw.invalid_action')
      end

      it 'passes supported action for coin' do
        api_post url, token: token, params: { action: 'accept', id: coin.id }

        expect(response).not_to include_api_error('admin.withdraw.invalid_action')
      end

      it 'passes supported action for fiat' do
        api_post url, token: token, params: { action: 'reject', id: fiat.id }

        expect(response).not_to include_api_error('admin.withdraw.invalid_action')
      end

      it 'does not pass coin action for fiat' do
        api_post url, token: token, params: { action: 'load', id: fiat.id, txid: 'txid' }

        expect(response.status).to eq 422
        expect(response).to include_api_error('admin.withdraw.invalid_action')
      end

      it 'requests txid on load' do
        api_post url, token: token, params: { action: 'load', id: coin.id }

        expect(response.status).to eq 422
        expect(response).to include_api_error('admin.withdraw.missing_txid')
      end
    end

    context 'updates withdraw' do
      before { [coin, fiat].map(&:submit!) }

      it 'accept fiat' do
        api_post url, token: token, params: { action: 'accept', id: fiat.id }

        fiat.reload

        expect(fiat.aasm_state).to eq('succeed')
      end

      it 'accept coin' do
        api_post url, token: token, params: { action: 'accept', id: coin.id }

        coin.reload

        expect(coin.aasm_state).to eq('accepted')
      end

      it 'reject fiat' do
        api_post url, token: token, params: { action: 'reject', id: fiat.id }

        fiat.reload

        expect(fiat.aasm_state).to eq('rejected')
      end

      it 'reject coin' do
        api_post url, token: token, params: { action: 'reject', id: coin.id }

        coin.reload

        expect(coin.aasm_state).to eq('rejected')
      end

      it 'load coin' do
        api_post url, token: token, params: { action: 'accept', id: coin.id }
        api_post url, token: token, params: { action: 'load', id: coin.id, txid: 'new_txid' }

        coin.reload

        expect(coin.txid).to eq('new_txid')
        expect(coin.aasm_state).to eq('confirming')
      end
    end
  end
end
