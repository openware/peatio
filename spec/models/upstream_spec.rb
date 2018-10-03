# encoding: UTF-8
# frozen_string_literal: true

describe Upstream do
  let(:upstream) { build(:upstream, :binance) }

  context 'validations' do
    it 'checks valid record' do
      expect(upstream).to be_valid
    end

    it 'validates presence of key' do
      upstream.timeout = -1
      expect(upstream).to_not be_valid
      expect(upstream.errors.full_messages).to eq ["Timeout must be greater than or equal to 0"]
    end
  end

  describe '#service' do
    it 'returns binance upstream' do
      expect(upstream.service).to be_a(Peatio::Upstream::Binance)
    end

    it 'expects that upstream service is the same' do
      expect(upstream.service).to eq upstream.service
    end
  end
end
