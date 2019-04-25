# TODO: Require in gem loading.
require_relative 'error'

module Peatio
  module Wallet
    # @abstract Represents basic blockchain wallet interface.
    #
    # Subclass and override abstract methods to implement
    # a peatio plugable wallet.
    # Than you need to register your wallet implementation.
    #
    # @see Bitcoin::Wallet Bitcoin as example of Abstract imlementation.
    #
    # @example
    #
    #   class MyWallet < Peatio::Abstract::Wallet
    #     def create_address(options = {})
    #       # do something
    #     end
    #     ...
    #   end
    #
    #   # Register MyWallet as peatio plugable wallet.
    #   Peatio::WalletAPI.register(:my_wallet, MyWallet.new)
    #
    # @author
    #   Yaroslav Savchuk <savchukyarpolk@gmail.com> (https://github.com/ysv)
    class Abstract
      # Current wallet settings for performing API calls.
      #
      # @abstract
      #
      # @!attribute [r] settings
      # @return [Hash] current wallet settings.
      attr_reader :settings

      # List of configurable settings.
      #
      # @see #configure
      SUPPORTED_SETTINGS = %i[wallet currency].freeze


      # Abstract constructor.
      #
      # @example
      #   class MyWallet< Peatio::Abstract::Wallet
      #
      #     # You could customize your wallet by passing features.
      #     def initialize(my_custom_features = {})
      #       @features = my_custom_features
      #     end
      #     ...
      #   end
      #
      #   # Register MyWallet as peatio plugable wallet.
      #   custom_features = {cash_addr_format: true}
      #   Peatio::BlockchainAPI.register(:my_wallet, MyWallet.new(custom_features))
      #
      # @abstract
      def initialize(*)
        abstract_method
      end

      # Merges given configuration parameters with defined during initialization
      # and returns the result.
      #
      # @param [Hash] settings configurations to use.
      # @option settings [Hash] :wallet Wallet settings for performing API calls.
      # With :address required key other settings could be customized
      # using Wallet#settings.
      # @option settings [Hash] :currency Currency settings with
      # :id,:base_factor,:options keys.
      #
      # @return [Hash] merged settings.
      def configure(settings = {})
        abstract_method
      end

      # Performs API call for address creation and returns it.
      #
      # @param [Hash] options
      #
      # @options options [String] :uid User UID which requested address creation.
      #
      # @return [Peatio::BlockchainAddress] newly created blockchain address.
      # @raise [Peatio::Blockchain::ClientError] if error was raised
      #   on wallet API call.
      def create_address!(options = {})
        abstract_method
      end

      # Performs API call for creating transaction and returns updated transaction.
      #
      # @param [Peatio::Transaction] transaction transaction with defined
      # to_address, amount & currency_id.
      #
      # @note You need to subtract fee from amount you send.
      #       It means that you need to deduct fee from the declared in
      #       transaction.
      #       If transaction amount is 1.0 and estimated fee is 0.01
      #       you need to send 0.09.
      #
      # @return [Peatio::Transaction] transaction with updated hash.
      # @raise [Peatio::Blockchain::ClientError] if error was raised
      #   on wallet API call.
      def create_transaction!(transaction)
        abstract_method
      end

      # Performs API call(s) for preparing for deposit collection.
      # E.g deposits ETH for collecting ERC20 tokens in case of Ethereum blockchain.
      #
      # @param [Peatio::Transaction] deposit_transaction transaction which
      # describes received deposit.
      #
      # @param [Array<Peatio::Transaction>] spread_transactions result of deposit
      # spread between wallets.
      #
      # @return [Array<Peatio::Transaction>] transaction created for
      # deposit collection preparing.
      def prepare_deposit_collection!(deposit_transaction, spread_transactions)
        # This method is mostly used for coins which needs additional fees
        # to be deposited before deposit collection.
      end

      private

      def abstract_method
        method_not_implemented
      end
    end
  end
end
