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

  context 'fields validations' do
    it 'validates units non equivalence' do
      record = Market.new(ask_unit: :btc, bid_unit: :btc)
      record.save
      expect(record.errors.full_messages).to include(/Ask unit is invilid/i)
    end

    it 'validates units presence' do
      record = Market.new(ask_unit: :btc)
      record.save
      expect(record.errors.full_messages).to include(/Bid unit can't be blank/i)
    end

    it 'validates units fee presence' do
      record = Market.new(ask_unit: :btc)
      record.save
      expect(record.errors.full_messages).to include(/Bid unit can't be blank/i)
    end

    it 'validates uniqueness of ID' do
      record = Market.new(ask_unit: :btc, bid_unit: :usd)
      record.save
      expect(record.errors.full_messages).to include(/id has already been taken/i)
    end
  end
end
