# encoding: UTF-8
# frozen_string_literal: true

describe ManagementAPIv1::Entities::Market do
  let(:record) { Market.first }

  subject { OpenStruct.new ManagementAPIv1::Entities::Market.represent(record).serializable_hash }
  it { expect(subject.name).to eq record.name }
  it { expect(subject.ask_unit).to eq record.ask_unit }
  it { expect(subject.bid_unit).to eq record.bid_unit }
  it { expect(subject.ask_fee).to eq record.ask_fee }
  it { expect(subject.bid_fee).to eq record.bid_fee }
  it { expect(subject.max_bid).to eq record.max_bid }
  it { expect(subject.min_ask).to eq record.min_ask }
  it { expect(subject.ask_precision).to eq record.ask_precision }
  it { expect(subject.bid_precision).to eq record.bid_precision }
  it { expect(subject.position).to eq record.position }
  it { expect(subject.enabled).to eq record.enabled }
end
