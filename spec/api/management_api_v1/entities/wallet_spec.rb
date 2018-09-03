# encoding: UTF-8
# frozen_string_literal: true

describe ManagementAPIv1::Entities::Wallet do
  let(:record) { Wallet.first }

  subject { OpenStruct.new ManagementAPIv1::Entities::Wallet.represent(record).serializable_hash }
  it { expect(subject.id).to eq record.id }
  it { expect(subject.currency_id).to eq record.currency_id }
  it { expect(subject.blockchain_key).to eq record.blockchain_key }
  it { expect(subject.address).to eq record.address }
  it { expect(subject.max_balance).to eq record.max_balance }
  it { expect(subject.kind).to eq record.kind }
  it { expect(subject.nsig).to eq record.nsig }
  it { expect(subject.parent).to eq record.parent }
  it { expect(subject.status).to eq record.status }
  it { expect(subject.gateway).to eq record.gateway }
  it { expect(subject.settings).to eq record.settings }
end
