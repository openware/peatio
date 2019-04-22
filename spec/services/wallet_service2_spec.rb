# encoding: UTF-8
# frozen_string_literal: true

class FakeBlockchain < Peatio::Blockchain::Abstract
  def initialize
    @features = {cash_addr_format: false, case_sensitive: true}
  end

  def configure(settings = {}); end
end

class FakeWallet < Peatio::Wallet::Abstract
  def initialize; end

  def configure(settings = {}); end
end

describe WalletService2 do
  let!(:blockchain) { create(:blockchain, 'fake-testnet') }
  let(:currency) { create(:currency, :fake) }
  let(:wallet) { create(:wallet, :fake_hot) }

  let(:fake_wallet_adapter) { FakeWallet.new }
  let(:fake_blockchain_adapter) { FakeBlockchain.new }

  let(:service) { WalletService2.new(wallet) }

  before do
    Peatio::BlockchainAPI.expects(:adapter_for)
                         .with(:fake)
                         .returns(fake_blockchain_adapter)
                         .at_least_once

    Peatio::WalletAPI.expects(:adapter_for)
                     .with(:fake)
                     .returns(fake_wallet_adapter)
                     .at_least_once

    Blockchain.any_instance.stubs(:blockchain_api).returns(BlockchainService2.new(blockchain))
  end

  context :create_address! do
    let(:account) { create(:member, :level_3, :barong).ac(currency)  }
    let(:blockchain_address) do
      Peatio::BlockchainAddress.new(address: :fake_address,
                                    secret: :changeme,
                                    details: { uid: account.member.uid })
    end

    before do
      fake_wallet_adapter.expects(:create_address!).returns(blockchain_address)
    end

    it 'creates address' do
      expect(service.create_address!(account)).to eq blockchain_address
    end
  end

  context :build_withdrawal! do
    let(:withdrawal) { OpenStruct.new(rid: 'fake-address', amount: 100) }

    let(:transaction) do
      Peatio::Transaction.new(hash:        '0xfake',
                              to_address:  withdrawal.rid,
                              amount:      withdrawal.amount,
                              currency_id: currency.id)
    end

    before do
      fake_wallet_adapter.expects(:create_transaction!).returns(transaction)
    end

    it 'sends withdrawal' do
      expect(service.build_withdrawal!(withdrawal)).to eq transaction
    end
  end
end
