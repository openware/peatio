# encoding: UTF-8
# frozen_string_literal: true

describe Matching::Engine do
  let(:market) { Market.find('btcusd') }
  let(:price)  { 10.to_d }
  let(:volume) { 5.to_d }
  let(:ask)    { Matching.mock_limit_order(type: :ask, price: price, volume: volume) }
  let(:bid)    { Matching.mock_limit_order(type: :bid, price: price, volume: volume) }

  let(:orderbook) { Matching::OrderBookManager.new('btcusd', broadcast: false) }
  subject         { Matching::Engine.new(market, mode: :run) }
  before          { subject.stubs(:orderbook).returns(orderbook) }

  context 'submit market order 2' do
    context 'market order out of locked 2' do
      subject { Matching::Engine.new(market, mode: :dryrun) }

      # We have the next state of ask(sell) order book.
      # | price | volume |
      # | 0.8006| 0.9817 |
      #
      # Bid market order for 0.8395 BTC was created with 0.6716 USD locked
      # (estimated average price is 0.8). But orderbook state changed and order doesn't
      # have enough locked to match with first in orderbook.
      # We expect order to be cancelled.
      let!(:ask1_in_db) do
        create(:order_ask,
               :btcusd,
               price: 80.06.to_d,
               volume: 0.9817.to_d)
      end

      let!(:bid1_in_db) do
        create(:order_bid,
               :btcusd,
               ord_type: :market,
               locked: 67.16.to_d,
               price: nil,
               volume: 0.8395.to_d)
      end

      let!(:ask1_mock) do
        Matching.mock_limit_order(id: ask1_in_db.id,
                                  type: :ask,
                                  price: ask1_in_db.price,
                                  volume: ask1_in_db.volume,
                                  timestamp: 1562668113)
      end

      let!(:bid1_mock) do
        Matching.mock_market_order(id: bid1_in_db.id,
                                   type: :bid,
                                   locked: bid1_in_db.locked,
                                   volume: bid1_in_db.volume,
                                   timestamp: 1562668113)
      end

      let(:expected_messages) do
        [
          [
            :order_processor,
            {
              :action=>"cancel",
              :order=>
                {:id=>bid1_in_db.id,
                 :timestamp=>1562668113,
                 :type=>:bid,
                 :locked=>67.16.to_d,
                 :volume=>0.8395.to_d,
                 :market=>"btcusd",
                 :ord_type=>"market"}
            },
            {:persistent=>false}
          ]
        ]
      end
      it 'publish single trade and cancel order' do
        subject.submit ask1_mock
        subject.submit bid1_mock
        expect(subject.queue).to eq expected_messages
      end
    end

    context 'market order out of locked 2' do
      subject { Matching::Engine.new(market, mode: :dryrun) }

      # We have the next state of ask(sell) order book.
      # | price | volume |
      # | 0.8006| 0.0111 |
      # | 1.4117| 0.9346 |
      #
      # Bid market order for 0.8395 BTC was created with 0.47237199 USD locked
      # (estimated average price is 0.562682).
      # But orderbook state changed and order doesn't have enough locked to
      # fulfill. We expect order to be partially filled and then cancelled.
      # For full order execution we need 1.181463512078
      # (0.0111 * 0.8006 + 0.83061334 * 1.4117). Which is less then locked.
      let!(:ask1_in_db) do
        create(:order_ask,
               :btcusd,
               price: 80.06.to_d,
               volume: 0.0111.to_d)
      end

      let!(:ask2_in_db) do
        create(:order_ask,
               :btcusd,
               price: 141.17.to_d,
               volume: 0.9346.to_d)
      end

      let!(:bid1_in_db) do
        create(:order_bid,
               :btcusd,
               ord_type: :market,
               locked: 47.237199.to_d,
               price: nil,
               volume: 0.8395.to_d)
      end

      let!(:ask1_mock) do
        Matching.mock_limit_order(id: ask1_in_db.id,
                                  type: :ask,
                                  price: ask1_in_db.price,
                                  volume: ask1_in_db.volume,
                                  timestamp: 1562668113)
      end

      let!(:ask2_mock) do
        Matching.mock_limit_order(id: ask2_in_db.id,
                                  type: :ask,
                                  price: ask2_in_db.price,
                                  volume: ask2_in_db.volume,
                                  timestamp: 1562668113)
      end

      let!(:bid1_mock) do
        Matching.mock_market_order(id: bid1_in_db.id,
                                   type: :bid,
                                   locked: bid1_in_db.locked,
                                   volume: bid1_in_db.volume,
                                   timestamp: 1562668113)
      end

      let(:expected_messages) do
        [
          [
            :trade_executor,
            {
              :market_id=>"btcusd",
              :ask_id=>ask1_in_db.id,
              :bid_id=>bid1_in_db.id,
              :strike_price=>80.06.to_d,
              :volume=>0.0111.to_d,
              :funds=>0.888666.to_d
            },
            { persistent: false }
          ],
          [
            :order_processor,
            {
              :action=>"cancel",
              :order=>
                {:id=>bid1_in_db.id,
                 :timestamp=>1562668113,
                 :type=>:bid,
                 :locked=>46.348533.to_d,
                 :volume=>0.8284.to_d,
                 :market=>"btcusd",
                 :ord_type=>"market"}
            },
           {:persistent=>false}
          ]
        ]
      end
      it 'publish single trade and cancel order' do
        subject.submit ask1_mock
        subject.submit ask2_mock
        subject.submit bid1_mock
        expect(subject.queue).to eq expected_messages
      end
    end

    context 'market order out of locked 3' do
      subject { Matching::Engine.new(market, mode: :dryrun) }

      # We have the next state of ask(sell) order book.
      # | price | volume |
      # | 3000.0| 0.0009 |
      # | 3001.0| 0.0011 |
      # | 3010.0| 0.1000 |
      #
      # Bid market order for 0.01 BTC was created with 30.03 USD locked
      # (estimated average price is 3003).
      # But orderbook state changed and order doesn't have enough locked to
      # fulfill. We expect order to create two trades and then cancel.
      # For full order execution we need 30.0811
      # (3000 * 0.0009 + 3001 * 0.0011 + 3010 * 0.008).
      # Which is less then locked.
      let!(:ask1_in_db) do
        create(:order_ask,
               :btcusd,
               price: 3000.to_d,
               volume: 0.0009.to_d)
      end

      let!(:ask2_in_db) do
        create(:order_ask,
               :btcusd,
               price: 3001.to_d,
               volume: 0.0011.to_d)
      end

      let!(:ask3_in_db) do
        create(:order_ask,
               :btcusd,
               price: 3010.to_d,
               volume: 0.1000.to_d)
      end

      let!(:bid1_in_db) do
        create(:order_bid,
               :btcusd,
               ord_type: :market,
               locked: 30.03.to_d,
               price: nil,
               volume: 0.01.to_d)
      end

      let!(:ask1_mock) do
        Matching.mock_limit_order(id: ask1_in_db.id,
                                  type: :ask,
                                  price: ask1_in_db.price,
                                  volume: ask1_in_db.volume,
                                  timestamp: 1562668113)
      end

      let!(:ask2_mock) do
        Matching.mock_limit_order(id: ask2_in_db.id,
                                  type: :ask,
                                  price: ask2_in_db.price,
                                  volume: ask2_in_db.volume,
                                  timestamp: 1562668113)
      end

      let!(:ask3_mock) do
        Matching.mock_limit_order(id: ask3_in_db.id,
                                  type: :ask,
                                  price: ask3_in_db.price,
                                  volume: ask3_in_db.volume,
                                  timestamp: 1562668113)
      end

      let!(:bid1_mock) do
        Matching.mock_market_order(id: bid1_in_db.id,
                                   type: :bid,
                                   locked: bid1_in_db.locked,
                                   volume: bid1_in_db.volume,
                                   timestamp: 1562668113)
      end

      let(:expected_messages) do
        [
          [
            :trade_executor,
            { :market_id=>"btcusd",
              :ask_id=>ask1_in_db.id,
              :bid_id=>bid1_in_db.id,
              :strike_price=>0.3e4,
              :volume=>0.9e-3,
              :funds=>0.27e1 },
            { :persistent=>false }
          ],
          [
            :trade_executor,
            { :market_id=>"btcusd",
              :ask_id=>ask2_in_db.id,
              :bid_id=>bid1_in_db.id,
              :strike_price=>0.3001e4,
              :volume=>0.11e-2,
              :funds=>0.33011e1 },
            { :persistent=>false }
          ],
          [
            :order_processor,
            { :action=>"cancel",
              :order=> {
                :id=>bid1_in_db.id,
                :timestamp=>1562668113,
                :type=>:bid,
                :locked=>0.240289e2,
                :volume=>0.8e-2,
                :market=>"btcusd",
                :ord_type=>"market"
              }},
            { :persistent=>false }
          ]
        ]
      end
      it 'publish single trade and cancel order' do
        subject.submit ask1_mock
        subject.submit ask2_mock
        subject.submit bid1_mock
        expect(subject.queue).to eq expected_messages
      end
    end

    context 'market doesn\'t have enough funds 1' do
      subject { Matching::Engine.new(market, mode: :dryrun) }

      # We have the next state of ask(sell) order book.
      # | price | volume |
      # | 3000.0| 0.0009 |
      #
      # Bid market order for 0.001 BTC was created with 30.03 USD locked
      # (estimated average price is 3003).
      # But orderbook state changed and market doesn't have enough volume to
      # fulfill. We expect order to match with the first opposite order and then
      # be cancelled.
      let!(:ask1_in_db) do
        create(:order_ask,
               :btcusd,
               price: 3000.to_d,
               volume: 0.0009.to_d)
      end

      let!(:bid1_in_db) do
        create(:order_bid,
               :btcusd,
               ord_type: :market,
               locked: 30.03.to_d,
               price: nil,
               volume: 0.01.to_d)
      end

      let!(:ask1_mock) do
        Matching.mock_limit_order(id: ask1_in_db.id,
                                  type: :ask,
                                  price: ask1_in_db.price,
                                  volume: ask1_in_db.volume,
                                  timestamp: 1562668113)
      end

      let!(:bid1_mock) do
        Matching.mock_market_order(id: bid1_in_db.id,
                                   type: :bid,
                                   locked: bid1_in_db.locked,
                                   volume: bid1_in_db.volume,
                                   timestamp: 1562668113)
      end

      let(:expected_messages) do
        [
          [
            :trade_executor,
            {
              :market_id=>"btcusd",
              :ask_id=>ask1_in_db.id,
              :bid_id=>bid1_in_db.id,
              :strike_price=>0.3e4,
              :volume=>0.9e-3,
              :funds=>0.27e1
            },
            { :persistent=>false }
          ],
          [
            :order_processor,
            {
              :action=>"cancel",
              :order=> {
                :id=>bid1_in_db.id,
                :timestamp=>1562668113,
                :type=>:bid,
                :locked=>0.2733e2,
                :volume=>0.91e-2,
                :market=>"btcusd",
                :ord_type=>"market"
              }
            },
          { :persistent=>false }
          ]
        ]
      end
      it 'publish single trade and cancel order' do
        subject.submit ask1_mock
        subject.submit bid1_mock
        expect(subject.queue).to eq expected_messages
      end
    end

    context 'market doesn\'t have enough funds 2' do
      subject { Matching::Engine.new(market, mode: :dryrun) }

      # We have the next state of ask(sell) order book.
      # | price | volume |
      # | 3000.0| 0.0009 |
      #
      # 1. Bid market order for 0.00045 BTC was created with 1.35 USD locked
      # (estimated average price is 3000).
      # 2. Bid market order for 0.0009 BTC was created with 2.7 USD locked
      # (estimated average price is 3000).
      # Firs order match fully. Second order match partially and cancel.
      let!(:ask1_in_db) do
        create(:order_ask,
               :btcusd,
               price: 3000.to_d,
               volume: 0.0009.to_d)
      end

      let!(:bid1_in_db) do
        create(:order_bid,
               :btcusd,
               ord_type: :market,
               locked: 1.35.to_d,
               price: nil,
               volume: 0.00045.to_d)
      end

      let!(:bid2_in_db) do
        create(:order_bid,
               :btcusd,
               ord_type: :market,
               locked: 2.7.to_d,
               price: nil,
               volume: 0.0009.to_d)
      end

      let!(:ask1_mock) do
        Matching.mock_limit_order(id: ask1_in_db.id,
                                  type: :ask,
                                  price: ask1_in_db.price,
                                  volume: ask1_in_db.volume,
                                  timestamp: 1562668113)
      end

      let!(:bid1_mock) do
        Matching.mock_market_order(id: bid1_in_db.id,
                                   type: :bid,
                                   locked: bid1_in_db.locked,
                                   volume: bid1_in_db.volume,
                                   timestamp: 1562668113)
      end

      let!(:bid2_mock) do
        Matching.mock_market_order(id: bid2_in_db.id,
                                   type: :bid,
                                   locked: bid2_in_db.locked,
                                   volume: bid2_in_db.volume,
                                   timestamp: 1562668113)
      end

      let(:expected_messages) do
        [
          [
            :trade_executor,
            {
              :market_id => "btcusd",
              :ask_id => ask1_in_db.id,
              :bid_id => bid1_in_db.id,
              :strike_price => 0.3e4.to_d,
              :volume => 0.45e-3.to_d,
              :funds => 0.135e1.to_d
            },
            { :persistent => false }
          ],
          [
            :trade_executor,
            {
              :market_id => "btcusd",
              :ask_id => ask1_in_db.id,
              :bid_id => bid2_in_db.id,
              :strike_price => 0.3e4.to_d,
              :volume => 0.45e-3.to_d,
              :funds => 0.135e1.to_d
            },
            { :persistent => false }
          ],
          [
            :order_processor,
            {
              :action => "cancel",
              :order => {
                :id => bid2_in_db.id,
                :timestamp => 1562668113,
                :type => :bid,
                :locked => 0.135e1.to_d,
                :volume => 0.45e-3.to_d,
                :market => "btcusd",
                :ord_type => "market"
              }
            },
            { :persistent => false }
          ]
        ]
      end
      it 'publish single trade and cancel order' do
        subject.submit ask1_mock
        subject.submit bid1_mock
        subject.submit bid2_mock
        expect(subject.queue).to eq expected_messages
      end
    end
  end

  context 'submit market order' do
    let!(:bid)  { Matching.mock_limit_order(type: :bid, price: '0.1'.to_d, volume: '0.1'.to_d) }
    let!(:ask1) { Matching.mock_limit_order(type: :ask, price: '1.0'.to_d, volume: '1.0'.to_d) }
    let!(:ask2) { Matching.mock_limit_order(type: :ask, price: '2.0'.to_d, volume: '1.0'.to_d) }
    let!(:ask3) { Matching.mock_limit_order(type: :ask, price: '3.0'.to_d, volume: '1.0'.to_d) }

    it 'should fill the market order completely' do
      mo = Matching.mock_market_order(type: :bid, locked: '6.0'.to_d, volume: '2.4'.to_d)

      AMQPQueue.expects(:enqueue).with(:trade_executor, { market_id: market.id, ask_id: ask1.id, bid_id: mo.id, strike_price: ask1.price, volume: ask1.volume, funds: '1.0'.to_d }, anything)
      AMQPQueue.expects(:enqueue).with(:trade_executor, { market_id: market.id, ask_id: ask2.id, bid_id: mo.id, strike_price: ask2.price, volume: ask2.volume, funds: '2.0'.to_d }, anything)
      AMQPQueue.expects(:enqueue).with(:trade_executor, { market_id: market.id, ask_id: ask3.id, bid_id: mo.id, strike_price: ask3.price, volume: '0.4'.to_d, funds: '1.2'.to_d }, anything)

      subject.submit bid
      subject.submit ask1
      subject.submit ask2
      subject.submit ask3
      subject.submit mo

      expect(subject.ask_orders.limit_orders.size).to eq 1
      expect(subject.ask_orders.limit_orders.values.first).to eq [ask3]
      expect(ask3.volume).to eq '0.6'.to_d

      expect(subject.bid_orders.market_orders).to be_empty
    end

    it 'should fill the market order partially and cancel it' do
      mo = Matching.mock_market_order(type: :bid, locked: '6.0'.to_d, volume: '2.4'.to_d)

      AMQPQueue.expects(:enqueue).with(:trade_executor, { market_id: market.id, ask_id: ask1.id, bid_id: mo.id, strike_price: ask1.price, volume: ask1.volume, funds: '1.0'.to_d }, anything)
      AMQPQueue.expects(:enqueue).with(:trade_executor, { market_id: market.id, ask_id: ask2.id, bid_id: mo.id, strike_price: ask2.price, volume: ask2.volume, funds: '2.0'.to_d }, anything)
      AMQPQueue.expects(:enqueue).with(:order_processor, has_entries(action: 'cancel', order: has_entry(id: mo.id)), anything)

      subject.submit bid
      subject.submit ask1
      subject.submit ask2
      subject.submit mo

      expect(subject.ask_orders.limit_orders).to be_empty
      expect(subject.bid_orders.market_orders).to be_empty
    end
  end

  context 'submit limit order' do
    context 'fully match incoming order' do
      it 'should execute trade' do
        AMQPQueue.expects(:enqueue)
                 .with(:trade_executor, { market_id: market.id, ask_id: ask.id, bid_id: bid.id, strike_price: price, volume: volume, funds: '50.0'.to_d }, anything)

        subject.submit(ask)
        subject.submit(bid)

        expect(subject.ask_orders.limit_orders).to be_empty
        expect(subject.bid_orders.limit_orders).to be_empty
      end
    end

    context 'partial match incoming order' do
      let(:ask) { Matching.mock_limit_order(type: :ask, price: price, volume: 3.to_d) }

      it 'should execute trade' do
        AMQPQueue.expects(:enqueue)
                 .with(:trade_executor, { market_id: market.id, ask_id: ask.id, bid_id: bid.id, strike_price: price, volume: 3.to_d, funds: '30.0'.to_d }, anything)

        subject.submit(ask)
        subject.submit(bid)

        expect(subject.ask_orders.limit_orders).to be_empty
        expect(subject.bid_orders.limit_orders).not_to be_empty

        AMQPQueue.expects(:enqueue)
                 .with(:order_processor, { action: 'cancel', order: bid.attributes }, anything)
        subject.cancel(bid)
        expect(subject.bid_orders.limit_orders).to be_empty
      end
    end

    context 'match order with many counter orders' do
      let(:bid)    { Matching.mock_limit_order(type: :bid, price: price, volume: 10.to_d) }

      let(:asks) do
        [nil, nil, nil].map do
          Matching.mock_limit_order(type: :ask, price: price, volume: 3.to_d)
        end
      end

      it 'should execute trade' do
        AMQPQueue.expects(:enqueue).times(asks.size)

        asks.each { |ask| subject.submit(ask) }
        subject.submit(bid)

        expect(subject.ask_orders.limit_orders).to be_empty
        expect(subject.bid_orders.limit_orders).not_to be_empty
      end
    end

    context 'fully match order after some cancellatons' do
      let(:bid)      { Matching.mock_limit_order(type: :bid, price: price, volume: 10.to_d) }
      let(:low_ask)  { Matching.mock_limit_order(type: :ask, price: price - 1, volume: 3.to_d) }
      let(:high_ask) { Matching.mock_limit_order(type: :ask, price: price, volume: 3.to_d) }

      it 'should match bid with high ask' do
        subject.submit(low_ask) # low ask enters first
        subject.submit(high_ask)
        subject.cancel(low_ask) # but it's canceled

        AMQPQueue.expects(:enqueue)
                 .with(:trade_executor, { market_id: market.id, ask_id: high_ask.id, bid_id: bid.id, strike_price: high_ask.price, volume: high_ask.volume, funds: '30.0'.to_d }, anything)
        subject.submit(bid)

        expect(subject.ask_orders.limit_orders).to be_empty
        expect(subject.bid_orders.limit_orders).not_to be_empty
      end
    end
  end

  context '#cancel' do
    it 'should cancel order' do
      subject.submit(ask)
      subject.cancel(ask)
      expect(subject.ask_orders.limit_orders).to be_empty

      subject.submit(bid)
      subject.cancel(bid)
      expect(subject.bid_orders.limit_orders).to be_empty
    end
  end

  context 'dryrun' do
    subject { Matching::Engine.new(market, mode: :dryrun) }

    it 'should not publish matched trades' do
      AMQPQueue.expects(:enqueue).never

      subject.submit(ask)
      subject.submit(bid)

      expect(subject.ask_orders.limit_orders).to be_empty
      expect(subject.bid_orders.limit_orders).to be_empty

      expect(subject.queue.size).to eq 1
      expect(subject.queue.first).to eq [:trade_executor, { market_id: market.id, ask_id: ask.id, bid_id: bid.id, strike_price: price, volume: volume, funds: '50.0'.to_d }, { persistent: false }]
    end
  end
end
