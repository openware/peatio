# encoding: UTF-8
# frozen_string_literal: true

require_relative 'constants'

module Matching
  class LimitOrder < AbstractOrder

    attr :id, :timestamp, :type, :price, :market
    attr_accessor :volume

    def initialize(attrs)
      @id         = attrs[:id]
      @timestamp  = attrs[:timestamp]
      @type       = attrs[:type].to_sym
      @volume     = attrs[:volume].to_d
      @price      = attrs[:price].to_d
      @market     = attrs[:market]

      raise OrderError.new(self, 'Order is not valid') unless valid?(attrs)
    end

    def trade_with(counter_order, counter_book)
      if counter_order.is_a?(LimitOrder)
        if crossed?(counter_order.price)
          trade_price  = counter_order.price
          trade_volume = [volume, counter_order.volume].min
          trade_funds  = trade_price * trade_volume
          [trade_price, trade_volume, trade_funds]
        end
      else
        # TODO: Decide what do we do here.
        Rails.logger.warn "TRADE WITH !!!!!"
      end
    end

    def fill(trade_price, trade_volume, trade_funds)
      raise NotEnoughVolume if trade_volume > @volume
      @volume -= trade_volume
    end

    def filled?
      volume <= ZERO
    end

    def crossed?(price)
      if type == :ask
        price >= @price # if people offer price higher or equal than ask limit
      else
        price <= @price # if people offer price lower or equal than bid limit
      end
    end

    def label
      "%d/$%s/%s" % [id, price.to_s('F'), volume.to_s('F')]
    end

    def valid?(attrs)
      type.in?(%i[ask bid]) && \
        id.present? && \
        timestamp.present? && \
        market.present? && \
        price > ZERO
    end

    def attributes
      { id: @id,
        timestamp: @timestamp,
        type: @type,
        volume: @volume,
        price: @price,
        market: @market,
        ord_type: 'limit' }
    end
  end
end
