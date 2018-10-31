# encoding: UTF-8
# frozen_string_literal: true

describe AccountingService::MemberEntry do
  let(:initial_balance) { 11.0.to_d }
  let(:initial_locked) { 9.0.to_d }
  let(:currency_id) { :btc }

  let(:account) { create_account(currency_id, balance: initial_balance, locked: initial_locked) }
  subject { AccountingService.find_or_create_for(account.member, currency_id) }

  it 'sums locked and balance' do
    expect(subject.amount).to be_d initial_balance + initial_locked
  end

  context 'operation amount less than account balance' do
    let(:deposit) { create(:deposit_btc, amount: 1, member: subject.member) }
    let(:withdraw) { create(:btc_withdraw, sum: 0.5, member: subject.member) }

    it 'creates operation, credit balance and does not change locked' do
      expect{
        subject.plus_funds(deposit.amount, deposit)
      }.to change{ subject.operations.count }

      expect(subject.balance).to eql(initial_balance + deposit.amount.to_d)
      expect(subject.locked).to eql(initial_locked)
    end

    it 'creates operation, debit balance and credit lock' do
      expect{
        subject.lock_funds(withdraw.sum, withdraw)
      }.to change{ subject.operations.count }

      expect(subject.balance).to eql(initial_balance - withdraw.sum.to_d)
      expect(subject.locked).to eql(initial_locked + withdraw.sum.to_d)
    end

    it 'creates operation, credit balance and debit lock' do
      expect{
        subject.unlock_funds(withdraw.sum, withdraw)
      }.to change{ subject.operations.count }

      expect(subject.balance).to eql(initial_balance + withdraw.sum.to_d)
      expect(subject.locked).to eql(initial_locked - withdraw.sum.to_d)
    end

    it 'creates operation, does not change balance and debit lock' do
      expect{
        subject.unlock_and_sub_funds(withdraw.sum, withdraw)
      }.to change{ subject.operations.count }

      expect(subject.balance).to eql(initial_balance)
      expect(subject.locked).to eql(initial_locked - withdraw.sum.to_d)
    end
  end

  context 'operation amount is negative' do
    let(:deposit) { create(:deposit_btc, amount: 1, member: subject.member) }
    let(:withdraw) { create(:btc_withdraw, sum: 0.5, member: subject.member) }

    it { expect { subject.plus_funds(-1, deposit) }.to raise_error(AccountingService::Error) }
    it { expect { subject.lock_funds(-1.0, withdraw) }.to raise_error(AccountingService::Error) }
    it { expect { subject.unlock_funds(-1.0, withdraw) }.to raise_error(AccountingService::Error) }
    it { expect { subject.unlock_and_sub_funds(-1.0, withdraw) }.to raise_error(AccountingService::Error) }
  end

  context 'operation is greater than balance/locked' do
    let(:withdraw) { create(:btc_withdraw, sum: 0.5, member: subject.member) }

    it 'should raise error on lock_funds' do
      expect{
        subject.lock_funds(40, withdraw)
      }.to raise_error(AccountingService::Error) { |e| expect(e.message).to eq 'Cannot lock funds (amount: 40).' }

      expect(subject.balance).to eql(initial_balance)
      expect(subject.locked).to eql(initial_locked)
    end

    it 'should raise error on unlock_funds' do
      expect{
        subject.unlock_funds(40, withdraw)
      }.to raise_error(AccountingService::Error) { |e| expect(e.message).to eq 'Cannot unlock funds (amount: 40).' }

      expect(subject.balance).to eql(initial_balance)
      expect(subject.locked).to eql(initial_locked)
    end

    it 'should raise error on unlock_and_sub_funds' do
      expect{
        subject.unlock_and_sub_funds(40, withdraw)
      }.to raise_error(AccountingService::Error) { |e| expect(e.message).to eq 'Cannot unlock funds (amount: 40).' }

      expect(subject.balance).to eql(initial_balance)
      expect(subject.locked).to eql(initial_locked)
    end
  end

  describe 'double operation' do
    let(:deposit) { create(:deposit_btc, amount: 1, member: subject.member) }
    let(:withdraw) { create(:btc_withdraw, sum: 1, member: subject.member) }

    it 'expect double operation funds' do
      subject.plus_funds(deposit.amount, deposit)
      subject.unlock_and_sub_funds(withdraw.sum, withdraw)
      expect(subject.balance).to eql(initial_balance + deposit.amount)
      expect(subject.locked).to eql(initial_locked - withdraw.sum)
    end
  end

  describe 'concurrent lock_funds' do
    let(:deposit) { create(:deposit_btc, amount: 1, member: subject.member) }
    let(:withdraw) { create(:btc_withdraw, sum: 0.5, member: subject.member) }

    it 'should raise error on the second lock_funds' do
      account1 = Account.find subject.accounts.first.id
      account2 = Account.find subject.accounts.first.id

      expect(subject.balance).to eq initial_balance

      expect do
        ActiveRecord::Base.transaction do
          account1.lock_funds(11, withdraw)
        end
        ActiveRecord::Base.transaction do
          account2.lock_funds(11, withdraw)
        end
      end.to raise_error(AccountingService::Error) { |e| expect(e.message).to eq 'Cannot lock funds (amount: 11).' }
      expect(subject.balance).to eq initial_balance - 11
    end
  end
end
