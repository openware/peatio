# encoding: UTF-8
# frozen_string_literal: true

describe ManagementAPIv1::Entities::Currency do
  let(:record) { Currency.first }

  subject { OpenStruct.new ManagementAPIv1::Entities::Currency.represent(record).serializable_hash }
  it { expect(subject.id).to eq record.id }
  it { expect(subject.blockchain_key).to eq record.blockchain_key}
  it { expect(subject.symbol).to eq record.symbol }
  it { expect(subject.type).to eq record.type }
  it { expect(subject.deposit_fee).to eq record.deposit_fee}
  it { expect(subject.quick_withdraw_limit).to eq record.quick_withdraw_limit }
  it { expect(subject.precision).to eq record.precision}
  it { expect(subject.withdraw_fee).to eq record.withdraw_fee }
  it { expect(subject.base_factor).to eq record.base_factor }
  it { expect(subject.icon_url).to eq record.icon_url }
  it { expect(subject.enabled).to eq record.enabled }

end
