# encoding: UTF-8
# frozen_string_literal: true

class FakeBlockchain < Peatio::Blockchain::Abstract
  def supports_cash_addr_format?
    false
  end

  def case_sensitive?
    true
  end
end

describe BlockchainService2 do

  let!(:blockchain) { Blockchain.create!(key: 'fake', name: 'fake', client: 'fake', status: 'active', height: 1) }
  let(:block_number) { 1 }
  let(:fake_adapter) { FakeBlockchain.new }
  let(:service) { BlockchainService2.new(blockchain) }

  let!(:fake_currency1) { Currency.create!(id: 'fake1', name: 'fake1', blockchain: blockchain, symbol: 'F') }
  let!(:fake_currency2) { Currency.create!(id: 'fake2', name: 'fake2', blockchain: blockchain, symbol: 'G') }

  let!(:member) { create(:member) }

  let(:transaction) {  Peatio::Transaction.new(hash: 'fake_txid', from_address: 'fake_address', to_address: 'fake_address', amount: 5, block_number: 3, currency_id: 'fake1', txout: 4) }

  before(:each) { }

  before do
    Peatio::BlockchainAPI.expects(:adapter_for).with('fake').returns(fake_adapter)
    fake_adapter.stubs(:latest_block_number).returns(4)
    # TODO: Remove me.
    Blockchain.any_instance.stubs(:blockchain_api).returns(fake_adapter)
  end

  describe 'Filter Deposits' do
    # For each hash create transaction.
    let(:expected_transactions) do
      [
        Peatio::Transaction.new(hash: 'fake_hash', from_address: 'fake_address2', to_address: 'fake_address', amount: 1, block_number: 2, currency_id: 'fake1', txout: 1),
        Peatio::Transaction.new(hash: 'fake_hash', from_address: 'fake_address', to_address: 'fake_address1', amount: 2, block_number: 2, currency_id: 'fake1', txout: 2),
        Peatio::Transaction.new(hash: 'fake_hash', from_address: 'fake_address1', to_address: 'fake_address2', amount: 3, block_number: 2, currency_id: 'fake2', txout: 3)
      ]
    end

    context 'single fake deposit was created during block processing' do
      before do
        PaymentAddress.create!(currency: fake_currency1,
                               account: member.accounts.find_by(currency: fake_currency1),
                               address: 'fake_address')
        fake_adapter.stubs(:fetch_block!).returns(expected_transactions)
        service.process_block(block_number)
      end

      subject { Deposits::Coin.where(currency: fake_currency1) }

      it { expect(subject.count).to eq 1 }

      context 'creates deposit with correct attributes' do
        before do
          fake_adapter.stubs(:fetch_block!).returns([transaction])
          service.process_block(block_number)
        end

        it { expect(subject.where(txid: transaction.hash,
                        amount: transaction.amount,
                        address: transaction.to_address,
                        block_number: transaction.block_number,
                        txout: transaction.txout).count).to eq 1 }
      end

      context 'process data one more time' do
        before do
          fake_adapter.stubs(:fetch_block!).returns(expected_transactions)
        end

        it { expect { service.process_block(block_number) }.not_to change { subject } }
      end
    end

    context 'two fake deposits for one currency was created during block processing' do
      before do
        PaymentAddress.create!(currency: fake_currency1,
          account: member.accounts.find_by(currency: fake_currency1),
          address: 'fake_address')
        PaymentAddress.create!(currency: fake_currency1,
          account: member.accounts.find_by(currency: fake_currency1),
          address: 'fake_address1')
        fake_adapter.stubs(:fetch_block!).returns(expected_transactions)
        service.process_block(block_number)
      end

      subject { Deposits::Coin.where(currency: fake_currency1) }

      it { expect(subject.count).to eq 2 }

      context 'one deposit was updated' do
        let!(:deposit) do
          Deposit.create!(currency: fake_currency1,
                          member: member,
                          amount: 5,
                          address: 'fake_address',
                          txid: 'fake_txid',
                          block_number: 0,
                          txout: 4,
                          type: Deposits::Coin)
        end
        before do
          fake_adapter.stubs(:fetch_block!).returns([transaction])
          service.process_block(block_number)
        end
        it { expect(Deposits::Coin.find_by(txid: transaction.hash).block_number).to eq(transaction.block_number) }
      end
    end

    context 'two fake deposits for two currency was created during block processing' do
      before do
        PaymentAddress.create!(currency: fake_currency1,
          account: member.accounts.find_by(currency: fake_currency1),
          address: 'fake_address')
        PaymentAddress.create!(currency: fake_currency2,
          account: member.accounts.find_by(currency: fake_currency2),
          address: 'fake_address2')
        fake_adapter.stubs(:fetch_block!).returns(expected_transactions)
        service.process_block(block_number)
      end

      subject { Deposits::Coin.where(currency: [fake_currency1, fake_currency2]) }

      it { expect(subject.count).to eq 2 }

      it 'create for two currency' do
        expect(Deposits::Coin.where(currency: fake_currency1).count).to eq 1
        expect(Deposits::Coin.where(currency: fake_currency2).count).to eq 1
      end
    end
  end
  # Deposit context: (mock fetch_block)
  #   * Single deposit in block which should be saved.
  #   * Multiple deposits in single block (one saved one updated).
  #   * Multiple deposits for 2 currencies in single block.
  #   * Multiple deposits in single transaction (different txout).
  #
  # Withdraw context: (mock fetch_block)
  #   * Single withdrawal.
  #   * Multiple withdrawals for single currency.
  #   * Multiple withdrawals for 2 currencies.
end
