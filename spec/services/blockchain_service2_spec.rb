# encoding: UTF-8
# frozen_string_literal: true

FakeBlockchain = Peatio::Blockchain::Abstract.new
Peatio::BlockchainAPI.register(:fake, FakeBlockchain)

describe BlockchainService2 do
  let!(:blockchain) { Blockchain.create!(key: 'fake', name: 'fake', client: 'fake', status: 'active', height: 1) }
  let(:service) { BlockchainService2.new(blockchain) }
  let!(:fake_currency) { Currency.create!(id: 'fake', name: 'fake', blockchain: blockchain, symbol: 'F') }
  let!(:fake_currency1) { Currency.create!(id: 'fake1', name: 'fake1', blockchain: blockchain, symbol: 'G') }
  let!(:member) { create(:member) }
  let(:block_number) { 1 }
  let(:transaction) {  Peatio::Transaction.new(hash: 'fake_hash', from_address: 'fake_address', to_address: 'fake_address', amount: 1, block_number: 2, currency_id: 'fake') }
  let(:expected_transactions) do 
    [
      Peatio::Transaction.new(hash: 'fake_hash', from_address: 'fake_address', to_address: 'fake_address', amount: 1, block_number: 2, currency_id: 'fake', txout: 1),
      Peatio::Transaction.new(hash: 'fake_hash', from_address: 'fake_address', to_address: 'fake_address', amount: 2, block_number: 2, currency_id: 'fake', txout: 2),
      Peatio::Transaction.new(hash: 'fake_hash', from_address: 'fake_address', to_address: 'fake_address', amount: 3, block_number: 2, currency_id: 'fake', txout: 3)
    ]
  end
  it do
    service.adapter.stubs(:fetch_block!).returns(expected_transactions)
    PaymentAddress.stubs(:where).returns([{ address: 'fake_address' }])
    PaymentAddress.stubs(:find_by).returns(member.accounts.first.payment_address)
    Deposits::Coin.any_instance.stubs(:blockchain_api).returns(FakeBlockchain)
    FakeBlockchain.class.any_instance.stubs(:case_sensitive?).returns(true)
    FakeBlockchain.class.any_instance.stubs(:supports_cash_addr_format?).returns(false)
    Blockchain.any_instance.stubs(:blockchain_api).returns(FakeBlockchain)
    FakeBlockchain.class.any_instance.stubs(:latest_block_number).returns(4)
    # allow(BlockchainClient::Fake).to recieve(:case_sensetive).and_return(false)
    service.process_block(1)
    expect(Deposit.count).to eq 3
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
