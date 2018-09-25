# encoding: UTF-8
# frozen_string_literal: true

class KLineService
  extend Memoist

  PERIOD = 60.freeze
  # OHCL - open, high, closing, and low prices.
  DEFAULT_GET_OHLC_LIMIT = 30.freeze

  def redis
    Redis.new(
      url:      ENV.fetch('REDIS_URL'),
      password: ENV['REDIS_PASSWORD'],
      db:       1
    )
  end
  memoize :redis

  attr_accessor :market_id, :period

  def initialize(marked_id, period)
    @market_id = marked_id
    @period    = period
  end

  def key
    "peatio:#{market_id}:k:#{period}"
  end
  memoize :key

  def points_length
    redis.llen(key)
  end
  memoize :points_length

  def first_timestamp
    ts_json = redis.lindex(key, 0)
    ts_json.blank? ? nil : JSON.parse(ts_json).first
  end
  memoize :first_timestamp

  def get_ohlc(options={})
    options = { limit: DEFAULT_GET_OHLC_LIMIT }
                .merge(options)
                .symbolize_keys
                .tap { |o| o.delete(:limit) if o[:time_from].present? && o[:time_to].present? }
    return [] if first_timestamp.blank?

    left_index  = left_index_for(options)
    right_index = right_index_for(options)
    return [] if right_index < left_index
    JSON.parse('[%s]' % redis.lrange(key, left_index, right_index).join(','))
  end

  private

  def left_index_for(options)
    left_offsets = [0]

    if options[:time_from].present?
      left_offsets << (options[:time_from] - first_timestamp) / 60 / period
    end

    if options[:limit].present?
      if options[:time_to].present?
        left_offsets << (options[:time_to] - first_timestamp) / 60 / period - options[:limit] + 1
      elsif options[:time_from].blank?
        left_offsets << points_length - options[:limit]
      end
    end
    left_offsets.max
  end

  def right_index_for(options)
    right_offsets = [points_length]

    if options[:time_to].present?
      right_offsets << (options[:time_to] - first_timestamp) / 60 / period
    end

    if options[:limit].present? && options[:time_from].present?
      right_offsets << (options[:time_from] - first_timestamp) / 60 / period + options[:limit] - 1
    end
    right_offsets.min
  end
end
