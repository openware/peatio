describe Market do
  context 'visible market' do
    it { expect(Market.visible.count).to eq(1) }
  end

  context 'market attributes' do
    subject { Market.find(:btcusd) }

    it 'id' do
      expect(subject.id).to eq 'btcusd'
    end

    it 'name' do
      expect(subject.name).to eq 'BTC/USD'
    end

    it 'base_unit' do
      expect(subject.base_unit).to eq 'btc'
    end

    it 'quote_unit' do
      expect(subject.quote_unit).to eq 'usd'
    end

    it 'visible' do
      expect(subject.visible).to be true
    end
  end

  context 'shortcut of global access' do
    let(:log) { Market.find(:btcusd) }

    it 'bids' do
      expect(log.bids).to be
    end

    it 'asks' do
      expect(log.asks).to be
    end

    it 'trades' do
      expect(log.trades).to be
    end

    it 'ticker' do
      expect(log.ticker).to be
    end
  end

  it 'validates equivalence of units' do
    record = Market.new(ask_unit: :btc, bid_unit: :btc)
    record.save
    expect(record.errors.full_messages).to include(/ask unit is invalid/i)
  end

  it 'validates presence of units' do
    record = Market.new(ask_unit: :btc)
    record.save
    expect(record.errors.full_messages).to include(/bid unit can't be blank/i)
  end

  it 'validates presence of units fee' do
    record = Market.new(ask_unit: :btc)
    record.save
    expect(record.errors.full_messages).to include(/bid unit can't be blank/i)
  end

  it 'validates uniqueness of ID' do
    record = Market.new(ask_unit: :btc, bid_unit: :usd)
    record.save
    expect(record.errors.full_messages).to include(/id has already been taken/i)
  end
end
