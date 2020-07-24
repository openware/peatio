# frozen_string_literal: true

module Workers
  module Daemons
    class Deposit < Base
      self.sleep_time = 60

      def process
        ::Deposit.processing.each do |deposit|
          Rails.logger.info { "Starting processing coin deposit with id: #{deposit.id}." }

          if deposit.spread.blank?
            deposit.spread_between_wallets!
            Rails.logger.warn { "The deposit was spreaded in the next way: #{deposit.spread}"}
          end

          wallet = Wallet.active.deposit.find_by(blockchain_key: deposit.currency.blockchain_key)
          unless wallet
            Rails.logger.warn { "Can't find active deposit wallet for currency with code: #{deposit.currency_id}."}
            next
          end
          service = WalletService.new(wallet)
          # Check if adapter has prepare_deposit_collection! implementation
          if service.adapter.class.instance_methods(false).include?(:prepare_deposit_collection!)
            collect_fee(deposit)
            # Will be processed after fee collection
            next if deposit.fee_processing?
          end

          process_deposit(deposit)
        end

        ::Deposit.fee_processing.where('updated_at < ?', 5.minute.ago).each do |deposit|
          Rails.logger.info { "Starting processing token deposit with id: #{deposit.id}." }

          process_deposit(deposit)
        rescue StandardError => e
          Rails.logger.error { "Failed to collect deposit #{deposit.id}. See exception details below." }
          report_exception(e)

          raise e if is_db_connection_error?(e)
        end
      end

      def process_deposit(deposit)
        wallet = Wallet.active.deposit.find_by(blockchain_key: deposit.currency.blockchain_key)
        service = WalletService.new(wallet)

        transactions = service.collect_deposit!(deposit, deposit.spread_to_transactions)

        # Save txids in deposit spread.
        deposit.update!(spread: transactions.map(&:as_json))

        Rails.logger.warn { "The API accepted deposit collection and assigned transaction ID: #{transactions.map(&:as_json)}." }

        deposit.dispatch!
      rescue StandardError => e
        Rails.logger.error { "Failed to collect deposit #{deposit.id}. See exception details below." }
        report_exception(e)

        raise e if is_db_connection_error?(e)
      end

      def collect_fee(deposit)
        fee_wallet = Wallet.active.fee.find_by(blockchain_key: deposit.currency.blockchain_key)
        unless fee_wallet
          Rails.logger.warn { "Can't find active fee wallet for currency with code: #{deposit.currency_id}."}
          return
        end

        transactions = WalletService.new(fee_wallet).deposit_collection_fees!(deposit, deposit.spread_to_transactions)
        deposit.fee_process! if transactions.present?
        Rails.logger.warn { "The API accepted token deposit collection fee and assigned transaction ID: #{transactions.map(&:as_json)}." }
      rescue StandardError => e
        Rails.logger.error { "Failed to collect deposit fee #{deposit.id}. See exception details below." }
        report_exception(e)

        raise e if is_db_connection_error?(e)
      end
    end
  end
end
