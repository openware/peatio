# encoding: UTF-8
# frozen_string_literal: true

describe Worker::DepositCollection do
  let(:deposit) do
    create(:deposit_btc)
      .tap { |d| d.accept! }
      .tap { |d| d.update!(spread: spread) }
  end
  let(:wallet) { Wallet.find_by_blockchain_key('btc-testnet') }
  let(:wallet_service) { WalletService2.new(wallet) }
  let(:txid) { Faker::Lorem.characters(64) }
  let(:spread) do
    [{ to_address: 'to-address', amount: 0.1 }]
  end

  before do
    collect_deposit_transactions = spread.each_with_index.map do |t, i|
      Peatio::Transaction.new(t.merge(hash: "hash-#{i}"))
    end
    WalletService2.any_instance
                  .expects(:collect_deposit!)
                  .with(deposit, anything)
                  .returns(collect_deposit_transactions)
  end

  it 'collect deposit and update spread' do
    expect(deposit.collected?).to be_falsey
    expect{ Worker::DepositCollection.new.process(deposit) }.to change{ deposit.reload.spread }
    expect(deposit.collected?).to be_truthy
  end
end
