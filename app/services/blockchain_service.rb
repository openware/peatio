module BlockchainService
  class BaseService

    def initialize(blockchain)
      @blockchain = blockchain
      @client     = BlockAPI[blockchain.key]
    end

    def current_height
      @blockchain.height
    end

    def is_address_available?(address, currency)
      Wallet.active.where(address: address, kind: 'deposit').exists? || PaymentAddress.where(currency: currency, address: address).exists?
    end

  end
end