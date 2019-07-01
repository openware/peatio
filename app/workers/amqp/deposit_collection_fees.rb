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
            logger.warn deposit_id: deposit.id,
                        message: "The deposit is now being processed by different worker or has been already processed. Skipping..."
            return
          end


          if deposit.spread.blank?
            deposit.spread_between_wallets!
            logger.warn deposit_id: deposit.id,
                        message: "The deposit was spreaded in the next way: #{deposit.spread}"
          end

          wallet = Wallet.active.fee.find_by(blockchain_key: deposit.currency.blockchain_key)
          unless wallet
            logger.warn deposit_id: deposit.id,
                        message: "Can't find active deposit wallet for currency with code: #{deposit.currency_id}."
            AMQPQueue.enqueue(:deposit_collection, id: deposit.id)
            return
          end

          transactions = WalletService.new(wallet).deposit_collection_fees!(deposit, deposit.spread_to_transactions)

          if transactions.present?
            logger.warn deposit_id: deposit.id,
                        message: "The API accepted deposit collection fees transfer and assigned transaction IDs: #{transactions.map(&:as_json)}."
          end

          AMQPQueue.enqueue(:deposit_collection, id: deposit.id)
          logger.warn deposit_id: deposit.id,
                      message: "Deposit collection job enqueue."
        rescue StandardError => e
          # Reraise db connection errors to start retry logic.
          if Retry::DB_EXCEPTIONS.any? { |exception| e.is_a?(exception) }
            logger.warn message: "Lost db connection"
            raise e
          end

          begin
            logger.error depsot_id: deposit.id,
                          message: "Failed to collect fee transfer. See exception details below."
            report_exception(e)
          ensure
            deposit.skip!
            logger.error { "Exit..." }
          end
        end
      end
    end
  end
end
