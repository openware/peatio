require 'spec_helper'

describe APIv2::Entities::Order do

  let(:order)  { create(:order_ask, currency: 'btccny', price: '12.326'.to_d, volume: '3.14', origin_volume: '12.13') }

  context 'default exposure' do
    subject { OpenStruct.new APIv2::Entities::Order.represent(order, {}).serializable_hash }

    it 'id' do
      expect(subject.id).to eq order.id
    end

    it 'price' do
      expect(subject.price).to eq order.price
    end

    it 'avg_price' do
      expect(subject.avg_price).to eq ::Trade::ZERO
    end

    it 'volume' do
      expect(subject.volume).to eq order.origin_volume
    end

    it 'remaining_volume' do
      expect(subject.remaining_volume).to eq order.volume
    end

    it 'executed_volume' do
      expect(subject.executed_volume).to eq (order.origin_volume - order.volume)
    end

    it 'state' do
      expect(subject.state).to eq order.state
    end

    it 'market' do
      expect(subject.market).to eq order.market
    end

    it 'created_at' do
      expect(subject.created_at).to eq order.created_at.iso8601
    end

    it 'side' do
      expect(subject.side).to eq 'sell'
    end

    it 'trades' do
      expect(subject.trades).to be_nil
    end

    it 'trades_count' do
      expect(subject.trades_count).to eq 0
    end
  end

  context 'full exposure' do
    it 'should expose related trades' do
      create(:trade, ask: order, volume: '8.0', price: '12')
      create(:trade, ask: order, volume: '0.99', price: '12.56')

      json = APIv2::Entities::Order.represent(order, type: :full).serializable_hash
      expect(json[:trades].size).to eq 2
    end
  end

end
