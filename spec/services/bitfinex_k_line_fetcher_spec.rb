# frozen_string_literal: true

describe BitfinexKLineFetcher do
  let(:service) { described_class.new(redis: KlineDB.redis) }
  let(:candles) do
    [first_candle, second_candle, third_candle, latest_candle]
  end
  let(:first_candle) { [1539185220, 6588.7, 6588.8, 6588.8, 6588.7, 2.9906] }
  let(:second_candle) { [1539185280, 6588.7, 6588.3, 6588.8, 6587, 12.8798] }
  let(:third_candle) { [1539185340, 6588.2, 6587.8, 6588.2, 6587.7, 0.486] }
  let(:latest_candle) { [1539185400, 6587.8, 6587.8, 6587.8, 6587.8, 0.0135] }
  let(:market) { 'btcusd' }

  after { KlineDB.redis.flushall }

  context 'when data is in redis' do
    before { KlineDB.redis.rpush("peatio:#{market}:k:1", candles) }

    context 'when start is lower than first time' do
      it 'returns first candle data' do
        result = service.fetch_candle_data(market: market, period: 1)
        expect(result).to eq first_candle
      end
    end

    context 'when start is in the interval' do
      it 'returns third candle data' do
        result = service.fetch_candle_data(market: market, period: 1, start: 1539185340)
        expect(result).to eq third_candle
      end

      it 'returns the latest candle data' do
        result = service.fetch_candle_data(market: market, period: 1, start: 1539185400)
        expect(result).to eq latest_candle
      end
    end
  end

  context 'when data is fetched from bitfinex' do
    around do |example|
      WebMock.disable_net_connect!
      example.run
      WebMock.allow_net_connect!
    end
    let(:raw_candles) do
      [[
          1539185400000,
          6587.8,
          6587.8,
          6587.8,
          6587.8,
          0.01346023
      ],
      [
          1539185340000,
          6588.2,
          6587.8,
          6588.2,
          6587.7,
          0.48599278
      ],
      [
          1539185280000,
          6588.7,
          6588.3,
          6588.8,
          6587,
          12.87979556
      ],
      [
          1539185220000,
          6588.7,
          6588.8,
          6588.8,
          6588.7,
          2.99061108
      ]
    ]
    end

    before do
      stub_request(:get, "https://api.bitfinex.com/v2/candles/trade:1m:tBTCUSD/hist?start=1539185220000")
        .to_return(status: 200, body: raw_candles.to_json, headers: {})

    end

    it 'fetch data and push to redis correctly' do
      service.fetch_candle_data(market: market, period: 1, start: 1539185220)
      data_from_redis = service.send(:fetch_redis_data, market: market, period: 1)
      expect(data_from_redis).to eq candles
    end
  end
end
