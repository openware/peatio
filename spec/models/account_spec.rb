# encoding: UTF-8
# frozen_string_literal: true

describe Account do
  let(:initial_balance) { 10.0 }
  let(:initial_locked) { 10.0 }

  subject { create_account(:btc) }

  describe '#payment_address' do
    it { expect(subject.payment_address).not_to be_nil }
    it { expect(subject.payment_address).to be_is_a(PaymentAddress) }
    context 'fiat currency' do
      subject { create_account(:usd).payment_address }
      it { is_expected.to be_nil }
    end
  end

  describe '.enabled' do
    before do
      create_account(:usd)
      create_account(:btc)
      create_account(:dash)
    end

    it 'returns the accounts with currency enabled' do
      currency = Currency.find(:dash)
      currency.transaction do
        currency.update_columns(enabled: false)
        expect(Account.enabled.count).to eq 21
        currency.update_columns(enabled: true)
      end
    end
  end

  describe '#payment_address!' do
    it 'returns the same payment address if address generation is in progress' do
      expect(subject.payment_address!).to eq subject.payment_address
    end

    it 'return new payment address if previous has address generated' do
      subject.payment_address.tap do |previous|
        previous.update!(address: '1JSmYcCjBGm7RbjPppjZ1gGTDpBEmTGgGA')
        expect(subject.payment_address!).not_to eq previous
      end
    end
  end
end
