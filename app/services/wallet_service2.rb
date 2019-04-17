class WalletService2
  attr_reader :wallet, :adapter

  def initialize(wallet)
    @wallet = wallet
    @adapter = Peatio::WalletAPI.adapter_for(wallet.gateway)
    @adapter.configure(wallet: @wallet.to_wallet_api_settings,
                       currency: @wallet.currency.to_blockchain_api_settings)
  end

  # @return Peatio::BlockchainAccount
  def create_address!(account)
    @adapter.create_address({ uid: account.member.uid })
  end


  def build_withdrawal!(withdrawal)
    @adapter.create_transaction(withdrawal.for_wallet_api)
  end

  def collect_deposit!(deposit)

  end

  def deposit_collection_fees(deposit)

  end
end
