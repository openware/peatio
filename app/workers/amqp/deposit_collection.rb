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

        logger.info message: "Deposit info", model: deposit


        deposit.with_lock do
          if deposit.collected?
            logger.warn message: "The deposit is now being processed by different worker or has been already processed. Skipping...",
                        model: deposit
            return
          end

          if deposit.spread.blank?
            deposit.spread_between_wallets!
            logger.warn message: "The deposit was spreaded", model: deposit
          end

          wallet = Wallet.active.deposit.find_by(currency_id: deposit.currency_id)

          unless wallet
            logger.warn message: "Can't find active deposit wallet.", model: deposit
            return
          end
          logger.warn message: "Starting collecting deposit.", model: deposit


          transactions = WalletService.new(wallet).collect_deposit!(deposit, deposit.spread_to_transactions)

          # Save txids in deposit spread.
          deposit.update!(spread: transactions.map(&:as_json))

          logger.warn message: "The API accepted deposit collection and assigned transaction ID: #{transactions}.",
                      model: deposit

          deposit.dispatch!
        rescue Exception => e
          begin
            Rails.logger.error { "Failed to collect deposit #{deposit.id}. See exception details below." }
            report_exception(e)
          ensure
            deposit.skip!
            Rails.logger.warn { "Deposit skipped." }
          end
        end
      end
    end
  end
end
