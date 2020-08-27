# encoding: UTF-8
# frozen_string_literal: true

describe WithdrawLimit, 'Relationships' do
  context 'belongs to currency' do
    context 'null currency_id' do
      subject { build(:withdraw_limit, kyc_level: 1) }
      it { expect(subject.valid?).to be_truthy }
    end

    context 'existing currency_id' do
      subject { build(:withdraw_limit, currency_id: :btc) }
      it { expect(subject.valid?).to be_truthy }
    end

    context 'non-existing currency_id' do
      subject { build(:withdraw_limit, currency_id: :uah) }
      it { expect(subject.valid?).to be_falsey }
    end
  end
end

describe WithdrawLimit, 'Validations' do
  before(:each) { WithdrawLimit.delete_all }

  context 'group presence' do
    context 'nil group' do
      subject { build(:withdraw_limit, currency_id: :eth, group: nil) }
      it { expect(subject.valid?).to be_falsey }
    end

    context 'empty string group' do
      subject { build(:withdraw_limit, currency_id: :eth, group: '') }
      it { expect(subject.valid?).to be_falsey }
    end
  end

  context 'group uniqueness' do
    context 'different currencies' do
      before { create(:withdraw_limit, currency_id: :btc, group: 'vip-1') }

      context 'same group' do
        subject { build(:withdraw_limit, currency_id: :eth, group: 'vip-1') }
        it { expect(subject.valid?).to be_truthy }
      end

      context 'different group' do
        subject { build(:withdraw_limit, currency_id: :eth, group: 'vip-2') }
        it { expect(subject.valid?).to be_truthy }
      end

      context ':any group' do
        before { create(:withdraw_limit, currency_id: :btc, group: :any) }
        subject { build(:withdraw_limit, currency_id: :eth, group: :any) }
        it { expect(subject.valid?).to be_truthy }
      end
    end

    context 'same currency' do
      before { create(:withdraw_limit, currency_id: :btc, group: 'vip-1') }

      context 'same group' do
        subject { build(:withdraw_limit, currency_id: :btc, group: 'vip-1') }
        it { expect(subject.valid?).to be_falsey }
      end

      context 'different group' do
        subject { build(:withdraw_limit, currency_id: :btc, group: 'vip-2') }
        it { expect(subject.valid?).to be_truthy }
      end

      context ':any group' do
        before { create(:withdraw_limit, currency_id: :btc, group: :any) }
        subject { build(:withdraw_limit, currency_id: :btc, group: :any) }
        it { expect(subject.valid?).to be_falsey }
      end
    end

    context 'same kyc_level' do
      before { create(:withdraw_limit, kyc_level: 1, currency_id: :btc, group: 'vip-1') }

      context 'same group' do
        subject { build(:withdraw_limit, kyc_level: 1, currency_id: :btc, group: 'vip-1') }
        it { expect(subject.valid?).to be_falsey }
      end

      context 'different group' do
        subject { build(:withdraw_limit, kyc_level: 1, currency_id: :btc, group: 'vip-2') }
        it { expect(subject.valid?).to be_truthy }
      end

      context ':any group' do
        before { create(:withdraw_limit, kyc_level: 1, currency_id: :btc, group: :any) }
        subject { build(:withdraw_limit, kyc_level: 1, currency_id: :btc, group: :any) }
        it { expect(subject.valid?).to be_falsey }
      end
    end

    context ':any currency' do
      before { create(:withdraw_limit, group: 'vip-1') }

      context 'same group' do
        subject { build(:withdraw_limit, group: 'vip-1') }
        it { expect(subject.valid?).to be_falsey }
      end

      context 'different group' do
        subject { build(:withdraw_limit, group: 'vip-2') }
        it { expect(subject.valid?).to be_truthy }
      end

      context ':any group' do
        before { create(:withdraw_limit, group: :any) }
        subject { build(:withdraw_limit, group: :any) }
        it { expect(subject.valid?).to be_falsey }
      end
    end

    context ':any kyc_level and currency' do
      before { create(:withdraw_limit, group: 'vip-1') }

      context 'same group' do
        subject { build(:withdraw_limit, group: 'vip-1') }
        it { expect(subject.valid?).to be_falsey }
      end

      context 'different group' do
        subject { build(:withdraw_limit, group: 'vip-2') }
        it { expect(subject.valid?).to be_truthy }
      end

      context ':any group' do
        before { create(:withdraw_limit, group: :any) }
        subject { build(:withdraw_limit, group: :any) }
        it { expect(subject.valid?).to be_falsey }
      end
    end
  end

  context 'limit_24_hour, limit_1_month numericality' do
    context 'non decimal limit_24_hour/limit_1_month' do
      subject { build(:withdraw_limit, limit_24_hour: '1', limit_1_month: '1') }
      it do
        expect(subject.valid?).to be_truthy
      end
    end

    context 'valid withdraw_limit' do
      subject { build(:withdraw_limit, limit_24_hour: 0.1, limit_1_month: 0.2) }
      it { expect(subject.valid?).to be_truthy }
    end
  end

  context 'currency_id presence' do
    context 'nil group' do
      subject { build(:withdraw_limit, currency_id: nil) }
      it { expect(subject.valid?).to be_falsey }
    end

    context 'empty string group' do
      subject { build(:withdraw_limit, currency_id: '') }
      it { expect(subject.valid?).to be_falsey }
    end
  end

  context 'currency_id inclusion in' do
    context 'invalid currency_id' do
      subject { build(:withdraw_limit, currency_id: :ethusd) }
      it { expect(subject.valid?).to be_falsey }
    end

    context 'valid withdraw_limit' do
      subject { build(:withdraw_limit, currency_id: :btc) }
      it { expect(subject.valid?).to be_truthy }
    end
  end
end

describe WithdrawLimit, 'Class Methods' do
  before(:each) { WithdrawLimit.delete_all }

  context '#for' do
    let!(:member) { create(:member) }


    context 'get withdraw_limit with kyc_level, currency_id and group' do
      let!(:member) { create(:member, level: 1) }
      before do
        create(:withdraw_limit, kyc_level: 1, currency_id: :btc, group: 'vip-0')
        create(:withdraw_limit, currency_id: :any, group: 'vip-0')
        create(:withdraw_limit, currency_id: :btc, group: :any)
        create(:withdraw_limit, currency_id: :any, group: :any)
      end

      let(:withdraw) { Withdraw.new(member: member, currency_id: :btc) }
      subject { WithdrawLimit.for(kyc_level: withdraw.member.level, group: withdraw.member.group, currency_id: withdraw.currency_id) }

      it do
        expect(subject).to be_truthy
        expect(subject.currency_id).to eq('btc')
        expect(subject.group).to eq('vip-0')
        expect(subject.kyc_level).to eq('1')
      end
    end

    context 'get withdraw_limit with currency_id and group' do
      before do
        create(:withdraw_limit, currency_id: :btc, group: 'vip-0')
        create(:withdraw_limit, currency_id: :any, group: 'vip-0')
        create(:withdraw_limit, currency_id: :btc, group: :any)
        create(:withdraw_limit, currency_id: :any, group: :any)
      end

      let(:withdraw) { Withdraw.new(member: member, currency_id: :btc) }
      subject { WithdrawLimit.for(kyc_level: withdraw.member.level, group: withdraw.member.group, currency_id: withdraw.currency_id) }

      it do
        expect(subject).to be_truthy
        expect(subject.currency_id).to eq('btc')
        expect(subject.group).to eq('vip-0')
      end
    end

    context 'get withdraw_limit with group' do
      before do
        create(:withdraw_limit, currency_id: :any, group: 'vip-1')
        create(:withdraw_limit, currency_id: :btc, group: :any)
        create(:withdraw_limit, currency_id: :any, group: :any)
      end

      let(:withdraw) { Withdraw.new(member: member, currency_id: :btc) }
      subject { WithdrawLimit.for(kyc_level: withdraw.member.level, group: withdraw.member.group, currency_id: withdraw.currency_id) }

      it do
        expect(subject).to be_truthy
        expect(subject.currency_id).to eq('btc')
        expect(subject.group).to eq('any')
      end
    end

    context 'get withdraw_limit with currency_id' do
      before do
        create(:withdraw_limit, currency_id: :any, group: 'vip-0')
        create(:withdraw_limit, currency_id: :btc, group: :any)
        create(:withdraw_limit, currency_id: :any, group: :any)
      end

      let(:withdraw) { Withdraw.new(member: member, currency_id: :eth) }
      subject { WithdrawLimit.for(kyc_level: withdraw.member.level, group: withdraw.member.group, currency_id: withdraw.currency_id) }

      it do
        expect(subject).to be_truthy
        expect(subject.currency_id).to eq('any')
        expect(subject.group).to eq('vip-0')
      end
    end

    context 'get default withdraw_limit' do
      before do
        create(:withdraw_limit, currency_id: :any, group: 'vip-1')
        create(:withdraw_limit, currency_id: :btc, group: :any)
        create(:withdraw_limit, currency_id: :any, group: :any)
      end

      let(:withdraw) { Withdraw.new(member: member, currency_id: :eth) }
      subject { WithdrawLimit.for(kyc_level: withdraw.member.level, group: withdraw.member.group, currency_id: withdraw.currency_id) }

      it do
        expect(subject).to be_truthy
        expect(subject.currency_id).to eq('any')
        expect(subject.group).to eq('any')
      end
    end

    context 'get default withdraw_limit (doesnt create it)' do
      let(:withdraw) { Withdraw.new(member: member, currency_id: :eth) }
      subject { WithdrawLimit.for(kyc_level: withdraw.member.level, group: withdraw.member.group, currency_id: withdraw.currency_id) }

      it do
        expect(subject).to be_truthy
        expect(subject.currency_id).to eq('any')
        expect(subject.group).to eq('any')
      end
    end
  end
end
