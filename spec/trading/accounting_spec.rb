describe 'Accounting' do
  let(:seller) { create(:member, :level_3, :barong) }
  let(:buyer) { create(:member, :level_3, :barong) }

  let :order_ask do
    create :order_ask, \
       bid:           :usd,
       ask:           :btc,
       market:        Market.find(:btcusd),
       state:         :wait,
       ord_type:      :limit,
       price:         '1'.to_d,
       volume:        '10000.0',
       origin_volume: '10000.0',
       locked:        '10000',
       origin_locked: '10000',
       member:        seller
  end

  let :order_bid do
    create :order_bid, \
       bid:           :usd,
       ask:           :btc,
       market:        Market.find(:btcusd),
       state:         :wait,
       ord_type:      :limit,
       price:         '1.2'.to_d,
       volume:        '10000',
       origin_volume: '10000',
       locked:        '12000',
       origin_locked: '12000',
       member:        buyer
  end

  let(:deposit_btc) { create(:deposit_btc, member: seller, amount: order_ask.locked, currency_id: :btc) }

  let(:deposit_usd) { create(:deposit_usd, member: buyer, amount: order_bid.locked, currency_id: :usd) }

  let :executor do
    ask = Matching::LimitOrder.new(order_ask.to_matching_attributes)
    bid = Matching::LimitOrder.new(order_bid.to_matching_attributes)
    Matching::Executor.new \
      market_id:    :btcusd,
      ask_id:       ask.id,
      bid_id:       bid.id,
      strike_price: '1.2',
      volume:       '10000',
      funds:        '12000'
  end

  before do
    deposit_btc.accept!
    deposit_usd.accept!

    order_bid.hold_account!.lock_funds!(order_bid.locked)
    order_bid.record_submit_operations!

    order_ask.hold_account!.lock_funds!(order_ask.locked)
    order_ask.record_submit_operations!

    executor.execute!
  end

  it 'assert that asset - liabilities = revenue - expense' do
    asset = Operations::Asset.balance
    liability = Operations::Liability.balance
    revenue = Operations::Revenue.balance
    expense = Operations::Expense.balance

    expect(asset.merge(liability){ |k, a, b| a - b}).to eq (revenue.merge(expense){ |k, a, b| a - b})
  end

  it 'assert the balance is 15 / 18$' do
    asset = Operations::Asset.balance
    liability = Operations::Liability.balance
    balance = asset.merge(liability){ |k, a, b| a - b}

    expect(balance.fetch(:btc)).to eq '15.0'.to_d
    expect(balance.fetch(:usd)).to eq '18.0'.to_d
  end
end