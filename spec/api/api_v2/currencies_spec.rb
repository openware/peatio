# encoding: UTF-8
# frozen_string_literal: true

describe APIv2::Currencies, type: :request do
  let(:member) do
    create(:member, :level_3).tap do |m|
      m.get_account(:btc).update_attributes(balance: 12.13,   locked: 3.14)
      m.get_account(:usd).update_attributes(balance: 2014.47, locked: 0)
    end
  end

  let(:key) do
      seconds  = Time.now.to_i
      seconds - (seconds % 5)
  end

  let(:ask) do
    create(
      :order_ask,
      market_id: 'btcusd',
      price: '12.326'.to_d,
      volume: '123.123456789',
      member: member
    )
  end

  let(:ask2) do
    create(
        :order_ask,
        market_id: 'btcusd',
        price: '35.0'.to_d,
        volume: '100.000',
        member: member
    )
  end

  let(:bid) do
    create(
        :order_bid,
        market_id: 'btcusd',
        price: '12.326'.to_d,
        volume: '123.123456789',
        member: member
    )
  end

  let(:bid2) do
    create(
      :order_bid,
      market_id: 'btcusd',
      price: '35.0'.to_d,
      volume: '100.000',
      member: member
    )
  end


  describe 'GET /api/v2/currency/trades' do
    before do
      create(:trade, ask: ask, volume: ask.volume,  price: ask.price, created_at: 2.hours.ago)
      create(:trade, bid: bid, volume: bid.volume, price: bid.price, created_at: 1.hours.ago)
      create(:trade, ask: ask2, volume: ask2.volume, price: ask2.price, created_at: 1.hours.ago)
      create(:trade, bid: bid2, volume: bid2.volume, price: bid2.price, created_at: 1.hours.ago)
      Global.any_instance.stubs(:time_key).returns(key)
      Rails.cache.write("peatio:btcusd:h24_volume:#{key}", Trade.where(market_id: "btcusd").h24.sum(:volume) || '0.0'.to_d )
    end

    after { KlineDB.redis.flushall }

    it 'should return all recent trades' do
      get '/api/v2/currency/trades', currency: 'btc'
      expect(response).to be_success

      expected = [{ eth: { price:'0.0', volume: '0.0', change: '+0.0%' } },
                  { usd: { price: '23.663', volume: '446.2468', change: '+0.0%' } }]

      expect(JSON.parse(response.body, symbolize_names: true)).to eq expected
    end
  end

  describe 'GET /api/v2/currencies' do
    it 'lists enabled currencies' do
      get '/api/v2/currencies'
      expect(response).to be_success
      expect(JSON.parse(response.body).size).to eq Currency.enabled.size
    end

    it 'lists enabled coins' do
      get '/api/v2/currencies', type: 'coin'
      expect(response).to be_success
      expect(JSON.parse(response.body).size).to eq Currency.coins.enabled.size
    end

    it 'lists enabled fiats' do
      get '/api/v2/currencies', type: 'fiat'
      expect(response).to be_success
      expect(JSON.parse(response.body).size).to eq Currency.fiats.enabled.size
      expect(JSON.parse(response.body, symbolize_names: true)).to eq [{id: 'usd', symbol: '$', type: 'fiat', deposit_fee: '0.0', withdraw_fee: '0.1', quick_withdraw_limit: '10.0', base_factor: 1, precision: 2}]
    end

    it 'returns error in case of invalid type' do
      get '/api/v2/currencies', type: 'invalid'
      expect(response).to have_http_status 422
    end
  end
end
