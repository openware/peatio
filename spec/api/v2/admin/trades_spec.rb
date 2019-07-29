# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Admin::Trades, type: :request do
  let(:uid) { 'ID00FEE1DEAD' }
  let(:email) { 'someone@mailbox.com' }
  let(:admin) { create(:member, :admin, :level_3, email: email, uid: uid) }
  let(:token) { jwt_for(admin) }
  let(:member) { create(:member, :level_3) }
  let(:member_token) { jwt_for(member) }

  describe 'GET /api/v2/admin/trades' do
    let!(:trades) do
      [
        create(:trade, :btcusd, price: 12.0.to_d, volume: 12.0, created_at: 3.days.ago),
        create(:trade, :btcusd, price: 3.0.to_d, volume: 3.0, created_at: 5.days.ago),
        create(:trade, :btcusd, price: 25.0.to_d, volume: 25.0, created_at: 1.days.ago, ask_member: member),
        create(:trade, :btcusd, price: 6.0.to_d, volume: 6.0, created_at: 5.days.ago, bid_member: member),
        create(:trade, :btcusd, price: 5.0.to_d, volume: 5.0, created_at: 5.days.ago, bid_member: member),
      ]
    end

    it 'entity provides correct fields' do
      api_get'/api/v2/admin/trades', token: token, params: { limit: 5 }
      result = JSON.parse(response.body).first
      keys = %w[id volume price funds ask_id bid_id created_at ask_member_uid bid_member_uid taker_type market]

      expect(result.keys).to match_array keys
      expect(result.values).not_to include nil
    end

    context 'authentication' do
      it 'requires token' do
        get '/api/v2/admin/trades'
        expect(response.code).to eq '401'
      end

      it 'validates permissions' do
        api_get'/api/v2/admin/trades', token: member_token
        expect(response.code).to eq '403'
        expect(response).to include_api_error('admin.ability.not_permitted')
      end

      it 'authenticate admin' do
        api_get'/api/v2/admin/trades', token: token
        expect(response).to be_successful
      end
    end

    context 'pagination' do
      it 'with default values' do
        api_get'/api/v2/admin/trades', token: token
        result = JSON.parse(response.body)

        expect(result.length).to eq trades.length
      end

      it 'validates limit' do
        api_get'/api/v2/admin/trades', token: token, params: { limit: 'meow' }
        expect(response).to include_api_error 'admin.trade.non_integer_limit'
      end

      it 'validates page' do
        api_get'/api/v2/admin/trades', token: token, params: { page: 'meow' }
        expect(response).to include_api_error 'admin.trade.non_integer_page'
      end

      it 'first 5 trades ordered by id' do
        api_get'/api/v2/admin/trades', token: token, params: { limit: 5 }
        result = JSON.parse(response.body)
        expected = trades[0...5]

        expect(result.map { |t| t['id'] }).to match_array expected.map(&:id)
      end

      it 'second 5 trades ordered by id' do
        api_get'/api/v2/admin/trades', token: token, params: { limit: 5, page: 2 }
        result = JSON.parse(response.body)
        expected = trades[5...10]

        expect(result.map { |t| t['id'] }).to match_array expected.map(&:id)
      end
    end

    context 'ordering' do
      it 'validates ordering' do
        api_get'/api/v2/admin/trades', token: token, params: { ordering: 'straight' }

        expect(response).not_to be_successful
      end

      it 'orders by price ascending' do
        api_get'/api/v2/admin/trades', token: token, params: { order_by: 'price', ordering: 'asc' }
        result = JSON.parse(response.body)
        expected = trades.sort { |a, b| a.price <=> b.price }

        expect(result.map { |t| t['id'] }).to match_array expected.map(&:id)
      end

      it 'orders by volume descending' do
        api_get'/api/v2/admin/trades', token: token, params: { order_by: 'price', ordering: 'asc' }
        result = JSON.parse(response.body)
        expected = trades.sort { |a, b| b.volume <=> a.volume }

        expect(result.map { |t| t['id'] }).to match_array expected.map(&:id)
      end
    end

    context 'filtering' do
      context 'with market' do
        it 'validates market param' do
          api_get'/api/v2/admin/trades', token: token, params: { market: 'btcbtc' }

          expect(response).to include_api_error "admin.market.doesnt_exist"
        end

        it 'filters by market' do
          api_get'/api/v2/admin/trades', token: token, params: { market: 'btcusd' }
          result = JSON.parse(response.body)

          expected = trades.select { |t| t.market_id == 'btcusd' }

          expect(result.map { |t| t['id'] }).to match_array expected.map(&:id)
        end
      end

      context 'with price' do
        it 'validates minimum price' do
          api_get'/api/v2/admin/trades', token: token, params: { price_from: 'meow' }
          expect(response).to include_api_error 'admin.trade.non_decimal_price'
        end

        it 'validates maximum price' do
          api_get'/api/v2/admin/trades', token: token, params: { price_to: 'meow' }
          expect(response).to include_api_error 'admin.trade.non_decimal_price'
        end

        it 'with minimum price' do
          api_get'/api/v2/admin/trades', token: token, params: { price_from: 10 }
          result = JSON.parse(response.body)
          expected = trades.select { |t| t.price >= 10 }

          expect(result.length).to eq 2
          expect(result.map { |t| t['id'] }).to match_array expected.map(&:id)
        end

        it 'with maximum price' do
          api_get'/api/v2/admin/trades', token: token, params: { price_to: 10 }
          result = JSON.parse(response.body)
          expected = trades.select { |t| t.price < 10 }

          expect(result.map { |t| t['id'] }).to match_array expected.map(&:id)
        end

        it 'with minimum and maximum prices' do
          api_get'/api/v2/admin/trades', token: token, params: { price_from: 5, price_to: 20 }
          result = JSON.parse(response.body)
          expected = trades.select { |t| t.price < 20.to_d && t.price >= 5.to_d }

          expect(result.map { |t| t['id'] }).to match_array expected.map(&:id)
        end
      end

      context 'with volume' do
        it 'validates minimum volume' do
          api_get'/api/v2/admin/trades', token: token, params: { volume_from: 'meow' }
          expect(response).to include_api_error 'admin.trade.non_decimal_volume'
        end

        it 'validates maximum volume' do
          api_get'/api/v2/admin/trades', token: token, params: { volume_to: 'meow' }
          expect(response).to include_api_error 'admin.trade.non_decimal_volume'
        end

        it 'with minimum volume' do
          api_get'/api/v2/admin/trades', token: token, params: { volume_from: 10 }
          result = JSON.parse(response.body)
          expected = trades.select { |t| t.volume >= 10 }

          expect(result.map { |t| t['id'] }).to match_array expected.map(&:id)
        end

        it 'with maximum volume' do
          api_get'/api/v2/admin/trades', token: token, params: { volume_to: 10 }
          result = JSON.parse(response.body)
          expected = trades.select { |t| t.volume < 10 }

          expect(result.map { |t| t['id'] }).to match_array expected.map(&:id)
        end

        it 'with minimum and maximum volumes' do
          api_get'/api/v2/admin/trades', token: token, params: { volume_from: 5, volume_to: 20 }
          result = JSON.parse(response.body)
          expected = trades.select { |t| t.volume < 20.to_d && t.volume >= 5.to_d }

          expect(result.map { |t| t['id'] }).to match_array expected.map(&:id)
        end
      end

      context 'with uid' do
        it 'returns orders for specific user (both maker and taker sides)' do
          api_get'/api/v2/admin/trades', token: token, params: { uid: member.uid }
          result = JSON.parse(response.body)
          expected = member.trades

          expect(result.map { |t| t['id'] }).to match_array expected.map(&:id)
        end

        it 'return error when user does not exist' do
          api_get'/api/v2/admin/trades', token: token, params: { uid: 'ID00DEADBEEF' }
          expect(response).to include_api_error 'admin.user.doesnt_exist'
        end

        it 'empty collection when user has no trades' do
          api_get'/api/v2/admin/trades', token: token, params: { uid: admin.uid }
          expect(JSON.parse(response.body)).to be_empty
        end
      end

      context 'with timestamps' do
        it 'validates created_at_from' do
          api_get'/api/v2/admin/trades', token: token, params: { created_at_from: 'yesterday' }
          expect(response).to include_api_error 'admin.trade.non_integer_created_at_from'
        end

        it 'validates created_at_to' do
          api_get'/api/v2/admin/trades', token: token, params: { created_at_to: 'today' }
          expect(response).to include_api_error 'admin.trade.non_integer_created_at_to'
        end

        it 'returns trades created after specidfied date' do
          api_get'/api/v2/admin/trades', token: token, params: { created_at_from: 4.days.ago.to_i }

          result = JSON.parse(response.body)
          expected = trades.select { |t| t.created_at >= 4.days.ago }

          expect(result.map { |t| t['id'] }).to match_array expected.map(&:id)
        end

        it 'return trades created before specidfied date' do
          api_get'/api/v2/admin/trades', token: token, params: { created_at_to: 2.days.ago.to_i }

          result = JSON.parse(response.body)
          expected = trades.select { |t| t.created_at < 2.days.ago }

          expect(result.map { |t| t['id'] }).to match_array expected.map(&:id)
        end

        it 'returns trades created after and before specidfied dates' do
          api_get'/api/v2/admin/trades', token: token, params: { created_at_from: 4.days.ago.to_i, created_at_to: 2.days.ago.to_i }
          result = JSON.parse(response.body)
          expected = trades.select { |t| t.created_at >= 4.days.ago && t.created_at < 2.days.ago }

          expect(result.map { |t| t['id'] }).to match_array expected.map(&:id)
        end
      end
    end
  end
end
