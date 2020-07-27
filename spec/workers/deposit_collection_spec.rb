# encoding: UTF-8
# frozen_string_literal: true

describe Workers::AMQP::DepositCollection do
  let(:deposit) do
    create(:deposit_btc)
      .tap { |d| d.accept! }
      .tap { |d| d.process }
      .tap { |d| d.update!(spread: spread) }
  end
  let(:wallet) { Wallet.find_by_blockchain_key('btc-testnet') }
  let(:wallet_service) { WalletService.new(wallet) }
  let(:txid) { Faker::Lorem.characters(64) }
  let(:spread) do
    [{ to_address: 'to-address', amount: 0.1, status: 'pending' }]
  end

  let(:collected_spread) do
    spread.each_with_index.map do |s, i|
      s.merge(hash: "hash-#{i}")
    end
  end

  context do
    before do
      transactions = collected_spread.map { |s| Peatio::Transaction.new(s) }
      expect_any_instance_of(WalletService)
                    .to receive(:collect_deposit!)
                    .with(instance_of(Deposits::Coin), anything)
                    .and_return(transactions)
    end

    it 'collect deposit and update spread' do
      expect(deposit.spread).to eq(spread)
      expect(deposit.collected?).to be_falsey
      expect{ Workers::AMQP::DepositCollection.new.process(deposit) }.to change{ deposit.reload.spread }
      expect(deposit.spread).to eq(collected_spread)
      expect(deposit.collected?).to be_truthy
    end
  end

  context do
    before do
      expect_any_instance_of(WalletService)
                    .to receive(:collect_deposit!)
                    .with(instance_of(Deposits::Coin), anything)
                    .and_return([])
    end

    it 'collect deposit with empty spread' do
      Workers::AMQP::DepositCollection.new.process(deposit)
      expect(deposit.reload.collected?).to be_truthy
    end
  end
end
