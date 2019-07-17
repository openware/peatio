# encoding: UTF-8
# frozen_string_literal: true

module Workers
  module AMQP
    class DepositCollectionFees < Base
      def process(payload)
        logger.info deposit_id: payload['id'], message: "Received request for deposit collection fees transfer."
        deposit = Deposit.find_by_id(payload['id'])

        unless deposit
          logger.warn id: payload['id'], message: 'The deposit with such id doesn\'t exist.'
          return
        end

        deposit.with_lock do
          if deposit.collected?
            logger.warn deposit_id: deposit.id, model: deposit
            return
          end


          if deposit.spread.blank?
            deposit.spread_between_wallets!
            logger.warn message: "The deposit was spreaded", model: deposit
          end

          wallet = Wallet.active.fee.find_by(blockchain_key: deposit.currency.blockchain_key)
          unless wallet
            logger.warn message: "Can't find active deposit wallet", model: deposit
            AMQPQueue.enqueue(:deposit_collection, id: deposit.id)
            return
          end

          transactions = WalletService.new(wallet).deposit_collection_fees!(deposit, deposit.spread_to_transactions)

          if transactions.present?
            logger.warn message: "The API accepted deposit collection fees transfer and assigned transaction IDs: #{transactions.map(&:as_json)}.",
                        model: deposit
          end

          AMQPQueue.enqueue(:deposit_collection, id: deposit.id)
          logger.warn message: "Deposit collection job enqueue.",
                      model: deposit
        rescue Exception => e
          begin
            Rails.logger.error { "Failed to collect fee transfer deposit #{deposit.id}. See exception details below." }
            report_exception(e)
          ensure
            deposit.skip!
            Rails.logger.error { "Exit..." }
          end
        end
      end
    end
  end
end
