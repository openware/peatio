require 'spec_helper'

describe APIv2::Entities::Member do

  let(:member) { create(:verified_member) }

  subject { OpenStruct.new APIv2::Entities::Member.represent(member).serializable_hash }

  before { Currency.stubs(:codes).returns(%w(cny btc)) }

  it 'sn' do
    expect(subject.sn).to eq member.sn
  end

  it 'name' do
    expect(subject.name).to eq member.name
  end

  it 'email' do
    expect(subject.email).to eq member.email
  end

  it 'activated' do
    expect(subject.activated).to be true
  end

  it 'accounts' do
    expect(subject.accounts).to match [{:currency=>'cny', :balance=>'0.0', :locked=>'0.0'}, {:currency=>'btc', :balance=>'0.0', :locked=>'0.0'}]
  end
end
