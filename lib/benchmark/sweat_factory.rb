module Benchmark
  class SweatFactory

    @@seq = 0

    class <<self
      def make_member
        @@seq += 1
        member = Member.create!(
          email: "user#{@@seq}@example.com"
        )
      end

      def make_order(klass, attrs={})
        klass.new({
          bid: Currency.fiats.first.id,
          ask: Currency.coins.first.id,
          state: Order::WAIT,
          market_id: "btc#{Currency.fiats.first.code}".to_sym,
          origin_volume: attrs[:volume],
          ord_type: "limit"
        }.merge(attrs))
      end
    end

  end
end
