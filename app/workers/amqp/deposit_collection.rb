# encoding: UTF-8
# frozen_string_literal: true

module Workers
  module AMQP
    class DepositCollection < Base
      def process(payload)
        logger.info deposit_id: payload['id'],
                    message: "Received request for deposit collection."
        deposit = Deposit.find_by_id(payload['id'])

        unless deposit
          logger.warn deposit_id: deposit.id,
                      message: "The deposit with id: #{payload['id']} doesn't exist."
          return
        end

        logger.info deposit_id: deposit.id,
                    message: "Deposit amount: #{deposit.amount}, deposit address: #{deposit.address}"

        deposit.with_lock do
          if deposit.collected?
            logger.warn deposit_id: deposit.id,
                        message: "The deposit is now being processed by different worker or has been already processed. Skipping..."
            return
          end

          if deposit.spread.blank?
            deposit.spread_between_wallets!
            logger.warn  deposit_id: deposit.id,
                          message: "The deposit was spreaded in the next way: #{deposit.spread}"
          end

          wallet = Wallet.active.deposit.find_by(currency_id: deposit.currency_id)

          unless wallet
            logger.warn  deposit_id: deposit.id,
                          message: "Can't find active deposit wallet for currency with code: #{deposit.currency_id}."
            return
          end
          logger.warn deposit_id: deposit.id,
                      message: "Starting collecting deposit."


          transactions = WalletService.new(wallet).collect_deposit!(deposit, deposit.spread_to_transactions)

          # Save txids in deposit spread.
          deposit.update!(spread: transactions.map(&:as_json))

          logger.warn deposit_id: deposit.id,
                      message: "The API accepted deposit collection and assigned transaction ID: #{transactions.map(&:as_json)}."

          deposit.dispatch!
        rescue StandardError => e
          # Reraise db connection errors to start retry logic.
          if Retry::DB_EXCEPTIONS.any? { |exception| e.is_a?(exception) }
            logger.warn message: "Lost db connection"
            raise e
          end

          begin
            logger.error deposit_id: deposit.id,
                          message: "Failed to collect deposit #{deposit.id}. See exception details below."
            report_exception(e)
          ensure
            deposit.skip!
            logger.warn  deposit_id: deposit.id,
                          message: "Deposit skipped."
          end
        end
      end
    end
  end
end
