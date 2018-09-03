# encoding: UTF-8
# frozen_string_literal: true

describe ManagementAPIv1::Entities::Blockchain do
  let(:record) { create(:blockchain, 'eth-mainet') }

  subject { OpenStruct.new ManagementAPIv1::Entities::Blockchain.represent(record).serializable_hash }
  it { expect(subject.key).to eq record.key }
  it { expect(subject.name).to eq record.name }
  it { expect(subject.client).to eq record.client }
  it { expect(subject.server).to eq record.server }
  it { expect(subject.height).to eq record.height }
  it { expect(subject.explorer_address).to eq record.explorer_address }
  it { expect(subject.explorer_transaction).to eq record.explorer_transaction }
  it { expect(subject.min_confirmations).to eq record.min_confirmations }
  it { expect(subject.status).to eq record.status }
end
