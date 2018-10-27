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

  it { expect(subject.unlock_and_sub_funds('1.0'.to_d).balance).to be_d '10' }
  it { expect(subject.unlock_and_sub_funds('1.0'.to_d).locked).to be_d '9' }

  it { expect(subject.sub_funds('0.1'.to_d).balance).to eql '9.9'.to_d }
  it { expect(subject.plus_funds('0.1'.to_d).balance).to eql '10.1'.to_d }
  it { expect(subject.unlock_funds('0.1'.to_d).locked).to eql '9.9'.to_d }
  it { expect(subject.unlock_funds('0.1'.to_d).balance).to eql '10.1'.to_d }
  it { expect(subject.lock_funds('0.1'.to_d).locked).to eql '10.1'.to_d }
  it { expect(subject.lock_funds('0.1'.to_d).balance).to eql '9.9'.to_d }

  it { expect(subject.sub_funds('10.0'.to_d).balance).to eql '0.0'.to_d }
  it { expect(subject.plus_funds('10.0'.to_d).balance).to eql '20.0'.to_d }
  it { expect(subject.unlock_funds('10.0'.to_d).locked).to eql '0.0'.to_d }
  it { expect(subject.unlock_funds('10.0'.to_d).balance).to eql '20.0'.to_d }
  it { expect(subject.lock_funds('10.0'.to_d).locked).to eql '20.0'.to_d }
  it { expect(subject.lock_funds('10.0'.to_d).balance).to eql '0.0'.to_d }

  it { expect { subject.sub_funds('11.0'.to_d) }.to raise_error(Account::AccountError) }
  it { expect { subject.lock_funds('11.0'.to_d) }.to raise_error(Account::AccountError) }
  it { expect { subject.unlock_funds('11.0'.to_d) }.to raise_error(Account::AccountError) }

  it { expect { subject.sub_funds('-1.0'.to_d) }.to raise_error(Account::AccountError) }
  it { expect { subject.plus_funds('-1.0'.to_d) }.to raise_error(Account::AccountError) }
  it { expect { subject.lock_funds('-1.0'.to_d) }.to raise_error(Account::AccountError) }
  it { expect { subject.unlock_funds('-1.0'.to_d) }.to raise_error(Account::AccountError) }
  it { expect { subject.sub_funds('0'.to_d) }.to raise_error(Account::AccountError) }
  it { expect { subject.plus_funds('0'.to_d) }.to raise_error(Account::AccountError) }
  it { expect { subject.lock_funds('0'.to_d) }.to raise_error(Account::AccountError) }
  it { expect { subject.unlock_funds('0'.to_d) }.to raise_error(Account::AccountError) }

  describe 'double operation' do
    let(:strike_volume) { '10.0'.to_d }
    let(:account) { create_account }

    it 'expect double operation funds' do
      expect do
        account.plus_funds(strike_volume)
        account.sub_funds(strike_volume)
      end.to_not(change { account.balance })
    end
  end

  describe 'concurrent lock_funds' do
    it 'should raise error on the second lock_funds' do
      account1 = Account.find subject.id
      account2 = Account.find subject.id

      expect(subject.reload.balance).to eq BigDecimal.new('10')

      expect do
        ActiveRecord::Base.transaction do
          account1.lock_funds(8)
        end
        ActiveRecord::Base.transaction do
          account2.lock_funds(8)
        end
      end.to raise_error(Account::AccountError) { |e| expect(e.message).to eq 'Cannot lock funds (amount: 8).' }

      expect(subject.reload.balance).to eq BigDecimal.new('2')
    end
  end
end
