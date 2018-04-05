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

  context 'validations' do
    it 'creates valid record' do
      record = Market.new(market_params)
      expect(record.save).to eq true
    end

    it 'validates equivalence of units' do
      record = Market.new(market_params.merge(bid_unit: market_params[:ask_unit]))
      record.save
      expect(record.errors.full_messages).to include(/ask unit is invalid/i)
    end

    it 'validates uniqueness of ID' do
      record = build(:market, :btcusd)
      record.save
      expect(record.errors.full_messages).to include(/id has already been taken/i)
    end

    it 'validates presence of units' do
      %i[bid ask].each do |unit|
        record = Market.new(market_params.except("#{unit}_unit".to_sym))
        record.save
        expect(record.errors.full_messages).to include(/#{unit} unit can't be blank/i)
      end
    end

    it 'validates that units fee numericality greater than 0' do
      %i[bid ask].each do |unit|
        record = Market.new(market_params.merge("#{unit}_fee".to_sym => -1))
        record.save
        expect(record.errors.full_messages).to include(/#{unit} fee must be greater than or equal to 0/i)
      end
    end

    def market_params
      { ask_unit: :btc,
        bid_unit: :xrp,
        bid_fee: 0.1,
        ask_fee: 0.2,
        ask_precision: 3,
        bid_precision: 4 }
    end
  end
end
