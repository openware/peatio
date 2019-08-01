# encoding: UTF-8
# frozen_string_literal: true

describe RevenueShare, 'Attributes' do

  subject { create(:revenue_share) }

  describe '#percent' do
    it 'divide parts per ten thousand by 100' do
      expect(subject.percent).to eq(subject.pptt.to_d / 100)
    end
  end

  describe '#percent=' do

    let(:new_percent) { generate(:percent) }

    it 'multiply percent by 100' do
      subject.percent = new_percent
      expect(subject.percent).to eq(new_percent)
      expect(subject.pptt).to eq(new_percent * 100)
    end

    it 'symbol,nil,Time value types' do
      [:percent, nil, Time.now].each do |percent_value|
        subject.percent = percent_value
        expect(subject.percent).to be_nil
        expect(subject.pptt).to be_nil
      end
    end

    it 'string type' do
      subject.percent = 'percent'
      expect(subject.percent).to eq(0.to_d)
      expect(subject.pptt).to eq(0.to_d)
    end

    it 'decimal type' do
      subject.percent = 2.75.to_d
      expect(subject.percent).to eq(2.75.to_d)
      expect(subject.pptt).to eq(275)
    end
  end
end

describe RevenueShare, 'Validations' do

  subject { build(:revenue_share) }

  describe 'percent numerically' do
    it 'greater than 0' do
      subject.percent = 0
      expect(subject.valid?).to be_falsey
      expect(subject).to include_ar_error(:percent, /must be greater than 0/)

      subject.percent = -generate(:percent)
      expect(subject.valid?).to be_falsey
      expect(subject).to include_ar_error(:percent, /must be greater than 0/)
    end

    describe 'less than or equal to' do
      it '100 if state is disabled' do
        subject.percent = 101
        subject.state = :disabled
        expect(subject.valid?).to be_falsey
        expect(subject).to include_ar_error(:percent, /must be less than or equal to 100/)
      end

      it '100 minus sum of active percents for member if active' do
        create(:revenue_share, member: subject.member, percent: 94.5)

        subject.percent = 6
        expect(subject.valid?).to be_falsey
        expect(subject).to include_ar_error(:percent, /must be less than or equal to 5.5/)

        subject.state = :disabled
        expect(subject.valid?).to be_truthy

        subject.state = :active
        subject.member = create(:member)
        expect(subject.valid?).to be_truthy
      end
    end
  end

  describe 'state inclusion' do
    context 'nil state' do
      it do
        subject.state = nil
        expect(subject.valid?).to be_falsey
        expect(subject).to include_ar_error(:state, /is not included in the list/)
      end
    end

    context 'invalid state' do
      it do
        subject.state = :invalid
        expect(subject.valid?).to be_falsey
        expect(subject).to include_ar_error(:state, /is not included in the list/)
      end
    end
  end
end
