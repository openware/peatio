# frozen_string_literal: true

module Jobs
  module Cron
    module WithdrawWatcher
      def self.process
        # Process withdraws with `under_review` state each minute
        ::Withdraws::Coin.under_review.each do |withdraw|
          @service = nil

          Rails.logger.info { "Starting processing coin withdraw with id: #{withdraw.id}." }

          unless withdraw.remote_id
            Rails.logger.warn { "Withdraw with id: #{withdraw.id} and state: #{withdraw.aasm_state} does not have a remote_id, skipping." }
            next
          end

          wallet = Wallet.active.joins(:currencies)
                         .find_by(currencies: { id: withdraw.currency_id }, kind: :hot)

          unless wallet
            Rails.logger.warn { "Can't find active hot wallet for currency with code: #{withdraw.currency_id}." }
            next
          end

          @service = WalletService.new(wallet)
          # Check if adapter has fetch_blockchain_transaction_id implementation
          next unless @service.adapter.class.instance_methods(false).include?(:fetch_blockchain_transaction_id)

          begin
            configure_service_adapter(withdraw)
            fetch_withdraw_txid(withdraw)
            Rails.logger.warn "Txid for withdraw #{withdraw.id} is not available" if withdraw.txid.nil?
          rescue StandardError => e
            Rails.logger.error { "Failed to fetch txId for withdraw #{withdraw.id}. See exception details below." }
            report_exception(e)
            raise e if is_db_connection_error?(e)
          end
        end

        ::Withdraws::Coin.confirming.each do |withdraw|
          unless withdraw.remote_id
            Rails.logger.warn { "Withdraw with id: #{withdraw.id} and state: #{withdraw.aasm_state} does not have a remote_id, skipping." }
            next
          end

          wallet = Wallet.active.joins(:currencies)
                         .find_by(currencies: { id: withdraw.currency_id }, kind: :hot)

          unless wallet
            Rails.logger.warn { "Can't find active hot wallet for currency with code: #{withdraw.currency_id}." }
            next
          end

          @service = WalletService.new(wallet)
          # Check if adapter has withdraw_confirmed? implementation
          next unless @service.adapter.class.instance_methods(false).include?(:withdraw_confirmed?)

          begin
            configure_service_adapter(withdraw)
            confirm_withdraw(withdraw)
          rescue StandardError => e
            Rails.logger.error { "Failed to confirm withdraw #{withdraw.id}. See exception details below." }
            report_exception(e)
            raise e if is_db_connection_error?(e)
          end
        end

        sleep 60
      end

      def self.configure_service_adapter(withdraw)
        @service.adapter.configure(wallet: @service.wallet.to_wallet_api_settings,
                                   currency: withdraw.currency.to_blockchain_api_settings)
      end

      def self.fetch_withdraw_txid(withdraw)
        withdraw.txid = @service.adapter.fetch_blockchain_transaction_id(withdraw.remote_id)
        return if withdraw.txid.blank?

        withdraw.save!
        withdraw.dispatch!
      end

      def self.confirm_withdraw(withdraw)
        withdraw.success! if @service.adapter.withdraw_confirmed?(withdraw.remote_id)
      end
    end
  end
end
