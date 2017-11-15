require 'spec_helper'

describe APIv2::Entities::Account do

  let(:account) { create(:account_btc) }

  subject { OpenStruct.new APIv2::Entities::Account.represent(account).serializable_hash }

  it 'currency' do
    expect(subject.currency).to eq 'btc'
  end

  it 'balance' do
    expect(subject.balance).to eq '100.0'
  end

  it 'locked' do
    expect(subject.locked).to eq '0.0'
  end
end
