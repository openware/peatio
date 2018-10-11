# encoding: UTF-8
# frozen_string_literal: true

class BitfinexKLineFetcher
  CANDLES_API = "https://api.bitfinex.com/v2/candles/trade"
  MS = 1_000
  AVAILABLE_FRAMES = ['1m', '5m', '15m', '30m', '1h', '3h', '6h', '12h', '1D', '7D'].freeze

  attr_reader :redis

  def initialize(redis:)
    @redis = redis
  end

  def fetch_candle_data(market:, period:, start: nil)
    start = ENV.fetch('BITFINEX_K_START', Time.new(2018, 7, 1)) if start.nil?
    start = start.to_i
    frame = period_to_frame(period)
    return [] unless AVAILABLE_FRAMES.include?(frame)

    candles = fetch_redis_data(market: market, period: period)
    if candles.any?
      # If first time greater or equal to start just return first candle data
      first_time = candles.first[0]
      return candles.first if first_time >= start
      # Find candle with cached candles if start in the interval first..last
      return candles.select { |candle| candle[0] == start }.first if candles.last[0] >= start
    end

    candles = fetch_bitfinex_data(market: market, start: start, frame: frame)
    push_to_redis(candles: candles, period: period, market: market)
    candles.first
  end

  private

  def fetch_bitfinex_data(market:, start:, frame:)
    response = Faraday.get("#{CANDLES_API}:#{frame}:t#{market.upcase}/hist", start: start * MS)
    if response.status == 429
      Rails.logger.info { "Rate limit exceeded. Sleep a minute" }
      sleep(60)
      return
    end

    response.assert_success!
            .yield_self { |r| JSON.parse(r.body) || [] }
            .yield_self do |candles|
              candles.map do |candle|
                mts, open, close, high, low, volume = candle
                [mts / MS, open, close, high, low, volume.round(4)]
              end.sort
            end
  end

  def period_to_frame(period)
    return "#{period}m" if period < 60
    return "#{period / 60}h"  if period < 1440

    "#{period / 60 / 24}D"
  end

  def fetch_redis_data(market:, period:)
    redis.lrange(key(market, period), 0, -1)
         .map { |c| c && JSON.parse(c) }
  end

  def push_to_redis(candles:, market:, period:)
    redis.rpush(key(market, period), candles)
  end

  def key(market, period)
    "peatio:#{market}:k:#{period}"
  end
end
