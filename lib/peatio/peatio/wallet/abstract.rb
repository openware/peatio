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
      # @see Abstract::SUPPORTED_SETTINGS for list of settings required by wallet.
      #
      # @!attribute [r] settings
      # @return [Hash] current wallet settings.
      attr_reader :settings

      # List of configurable settings.
      #
      # @see #configure
      SUPPORTED_SETTINGS = %i[server wallet].freeze

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
      #
      # @return [Peatio::Wallet::Abstract]
      def initialize(*)
        abstract_method
      end

      def configure(settings = {})
        abstract_method
      end

      def create_address!(options = {})
        abstract_method
      end

      def create_transaction!(withdrawal)
        abstract_method
      end

      def deposit_collection_fees!(deposit)
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
