require_relative '../injectors'

module Bench
  module Injectors
    class Dummy < Base
      extend Memoist

      def initialize(config)
        super
        config.reverse_merge!(default_config)
        %i[min_volume max_volume min_price max_price].each do |var|
          instance_variable_set(:"@#{var}", config[var])
        end
      end

      private

      def construct_order
        market = @markets.sample
        type = %w[OrderBid OrderAsk].sample
        { type:     type,
          state:    Order::WAIT,
          member:   @members.sample,
          market:   market,
          ask:      market.base_unit,
          bid:      market.quote_unit,
          ord_type: :limit,
          price:    rand(@min_price..@max_price),
          volume:   rand(@min_volume..@max_volume) }
      end

      def default_config
        { min_volume: 0.1,
          max_volume: 1,
          min_price:  0.5,
          max_price:  2 }
      end
      memoize :default_config
    end
  end
end
