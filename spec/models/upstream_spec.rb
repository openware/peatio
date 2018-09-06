# encoding: UTF-8
# frozen_string_literal: true

describe Upstream do
  context 'validations' do

    subject { build(:upstream, :binance) }

    it 'checks valid record' do
      expect(subject).to be_valid
    end

    it 'validates presence of key' do
      subject.timeout = -1
      expect(subject).to_not be_valid
      expect(subject.errors.full_messages).to eq ["Timeout must be greater than or equal to 0"]
    end

  end
end
