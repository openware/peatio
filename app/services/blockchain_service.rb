# encoding: UTF-8
# frozen_string_literal: true

class BlockchainService

  def initialize(blockchain)
    @blockchain = blockchain
    @client     = BlockAPI[blockchain.key]
  end

  def current_height
    @blockchain.height
  end
  
  def process_blockchain
    current_block   = @blockchain.height || 0
    latest_block    = @client.latest_block_number
    # binding.pry
    while current_block <= latest_block
      #binding.pry
      block_json          = @client.get_block(current_block)
      # binding.pry
      if block_json
        deposits = []
        transactions        = block_json.fetch('transactions')
        transactions.each do |tx|

          # check if valid transaction
          next if @client.invalid_transaction?(tx)

          # WARNING: shitty code
          ## {
          #binding.pry
          address = @client.to_address(tx)
          address_in_db = find_address_in_db(address)
          if address_in_db.present?

            # skip transaction if eth is transferred to Token Address
            next if address_in_db[:currency].code != "eth" && !@client.is_erc20_txn?(tx)
            next if address_in_db[:currency].code == "eth" && @client.is_erc20_txn?(tx)

            trn = @client.build_deposit(tx, block_json, latest_block, address_in_db[:currency])
            trn.fetch(:entries).each_with_index do |entry, i|

              deposits << {
                txid:           trn[:id],
                address:        entry[:address],
                amount:         entry[:amount],
                member:         address_in_db[:member],
                currency:       address_in_db[:currency],
                txout:          i,
                confirmations:  trn[:confirmations]
              }
            end
          end
          ## }

        end

        # Save single block deposits.
        deposits.each do |deposit_hash|
          # If deposit doesn't exist create it.
          deposit = Deposits::Coin.find_or_create_by!(deposit_hash.except(:confirmations))

          # Otherwise update confirmations amount for existing deposit.
          if deposit.confirmations != deposit_hash.fetch(:confirmations)
            deposit.update(confirmations: deposit_hash.fetch(:confirmations))
          end

          # Accept deposit if it received minimum confirmations for current blockchain.
          if @blockchain.deposit_confirmations > 0 && deposit.confirmations >= @blockchain.deposit_confirmations
            deposit.accept!
          end
        end
      end
      # Mark block as processed if both deposits and withdrawals were confirmed.
      @blockchain.update(height: current_block) if latest_block - current_block > @blockchain.confirmations_max

      # Process next block.
      current_block += 1

      # TODO: exceptions processing.
    end
  end

  private

  # TODO: make this method beautiful
  def find_address_in_db(address)
    pa = PaymentAddress.find_by(address: address ,currency_id: @blockchain.currencies.pluck(:id))

    # TODO: check if Deposit doesn't exist
    # example deposit_coin.rb
    # def deposit_entry_processable?(currency, tx, entry, index)
    #   PaymentAddress.where(currency: currency, address: entry[:address]).exists? &&
    #       !Deposit.where(currency: currency, txid: tx[:id], txout: index).exists?
    # end
    #
    #
    # TODO: return data in specia format
    return nil if pa.blank?
    {
        member: pa.account.member,
        currency: pa.currency
    }
  end
end
