class BlockchainService2
  attr_reader :blockchain, :adapter

  def initialize(blockchian)
    @blockchain = blockchian
    @adapter = Peatio::BlockchainAPI.adapter_for(blockchian.client.to_sym)
    @adapter.configure(server: @blockchain.server,
                       currencies: @blockchain.currencies.map(&:to_blockchain_api_settings))
  end

  def latest_block_number
    Rails.cache.fetch("latest_#{@blockchain.client}_block_number", expires_in: 5.seconds) do
      @adapter.latest_block_number
    end
  end

  def load_balance(address, currency_id)
    @adapter.load_balance(address, currency_id)
  end

  # @deprecated
  # TODO: Update me once we replace Blockchain#blokchain_api with Blockchain#blockchain_apiv2.
  def case_sensitive?
    @adapter.features.fetch(:case_sensitive) { @adapter.case_sensitive? }
  end

  # @deprecated
  # TODO: Update me once we replace Blockchain#blokchain_api with Blockchain#blockchain_apiv2.
  def supports_cash_addr_format?
    @adapter.features.fetch(:cash_addr_format) { @adapter.supports_cash_addr_format? }
  end

  def process_block(block_number)
    block = @adapter.fetch_block!(block_number)

    deposits = filter_deposits(block)
    withdrawals = filter_withdrawals(block)

    ActiveRecord::Base.transaction do
      deposits.each(&method(:update_or_create_deposit))
      withdrawals.each(&method(:update_withdrawal))
      # TODO: Do we update height ???
    end
    block
  end

  private
  def filter_deposits(block)
    # TODO: Process addresses in batch in case of huge number of PA.
    addresses = PaymentAddress.where(currency: @blockchain.currencies).pluck(:address)
    block.select { |transaction| transaction.to_address.in?(addresses) }
  end

  def filter_withdrawals(block)
    # TODO: Process addresses in batch in case of huge number of confirming withdrawals.
    withdraw_txids = Withdraws::Coin.confirming.where(currency: @blockchain.currencies).pluck(:txid)
    block.select { |transaction| transaction.hash.in?(withdraw_txids) }
  end

  def update_or_create_deposit(transaction)
    if transaction.amount <= Currency.find(transaction.currency_id).min_deposit_amount
      # Currently we just skip tiny deposits.
      Rails.logger.info do
        "Skipped deposit with txid: #{transaction.hash} with amount: #{transaction.hash}"\
        " to #{transaction.to_address} in block number #{transaction.block_number}"
      end
      return
    end

    deposit =
      Deposits::Coin.find_or_create_by!(
        currency_id: transaction.currency_id,
        txid: transaction.hash,
        txout: transaction.txout
      ) do |d|
        d.address = transaction.to_address
        d.amount = transaction.amount
        d.member = PaymentAddress.find_by(currency_id: transaction.currency_id, address: transaction.to_address).account.member
        d.block_number = transaction.block_number
      end

    deposit.update_column(:block_number, transaction.block_number)
    if deposit.confirmations >= @blockchain.min_confirmations && deposit.accept!
      deposit.collect!
    end
  end

  def update_withdrawal(transaction)
    withdrawal =
      Withdraws::Coin.confirming
        .find_by(currency_id: transaction.currency_id, txid: transaction.hash)

    # Skip non-existing in database withdrawals.
    if withdrawal.blank?
      Rails.logger.info { "Skipped withdrawal: #{transaction.hash}." }
      return
    end

    withdrawal.update_column(:block_number, transaction.block_number)

    if transaction.status == :fail
      withdrawal.fail!
    elsif transaction.status == :success && withdrawal.confirmations >= @blockchain.min_confirmations
      withdrawal.success!
    end
  end
end
