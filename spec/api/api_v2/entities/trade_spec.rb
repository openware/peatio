require 'spec_helper'

describe APIv2::Entities::Trade do

  let(:trade) { create(:trade, ask: create(:order_ask), bid: create(:order_bid)) }

  subject { OpenStruct.new APIv2::Entities::Trade.represent(trade, side: 'sell').serializable_hash }

  it 'id' do
    expect(subject.id).to eq trade.id
  end

  it 'price' do
    expect(subject.price).to eq trade.price
  end

  it 'volume' do
    expect(subject.volume).to eq trade.volume
  end

  it 'funds' do
    expect(subject.funds).to eq trade.funds
  end

  it 'market' do
    expect(subject.market).to eq trade.currency
  end

  it 'created_at' do
    expect(subject.created_at).to eq trade.created_at.iso8601
  end

  it 'side' do
    expect(subject.side).to eq 'sell'
  end

  it 'order_id' do
    expect(subject.order_id).to be_nil
  end
end
