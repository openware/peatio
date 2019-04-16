# encoding: UTF-8
# frozen_string_literal: true

module Peatio #:nodoc:
  module Blockchain #:nodoc:

    # @abstract Represent basic blockchain interface.
    #
    # Subclass and override abstract methods to implement
    # a peatio plugable blockchain.
    # Than you need to register your blockchain implementation.
    #
    # @example
    #
    #   class MyBlockchain < Peatio::Abstract::Blockchain
    #     def fetch_block(block_number)
    #       # do something
    #     end
    #     ...
    #   end
    #
    #   # Register MyBlockchain as peatio plugable blockchain.
    #   Peatio::BlockchainAPI.register(:my_blockchain, MyBlockchain.new)
    #
    # @author
    #   Yaroslav Savchuk <savchukyarpolk@gmail.com> (https://github.com/ysv)
    class Abstract

      # Current blockchain settings for performing API calls and building blocks.
      #
      # @abstract
      #
      # @!attribute [r] settings
      # @return [Hash] current blockchain settings.
      attr_reader :settings

      # Features supported by blockchain.
      #
      # @abstract
      #
      # @!attribute [r] features
      # @return [Hash] list of features supported by blockchain.
      attr_reader :features


      # List of all features supported by peatio.
      #
      # @todo
      #   Rename supports_cash_addr_format -> cash_addr_format.
      SUPPORTED_FEATURES = %i[case_sensitive supports_cash_addr_format].freeze

      # List of settings which should be configurable.
      #
      # @see #configure
      #
      # @todo checkme.
      SUPPORTED_SETTINGS = %i[server currencies].freeze

      # Abstract constructor.
      #
      # @example
      #   class MyBlockchain < Peatio::Abstract::Blockchain
      #
      #     DEFAULT_FEATURES = {case_sensitive: true, supports_cash_addr_format: false}.freeze
      #
      #     # You could override default features by passing them to initializer.
      #     def initialize(my_custom_features = {})
      #       @features = DEFAULT_FEATURES.merge(my_custom_features)
      #     end
      #     ...
      #   end
      #
      #   # Register MyBlockchain as peatio plugable blockchain.
      #   custom_features = {supports_cash_addr_format: true}
      #   Peatio::BlockchainAPI.register(:my_blockchain, MyBlockchain.new(custom_features))
      #
      # @abstract
      #
      # @return [Peatio::Blockchain::Abstract]
      def initialize(*)
        abstract_method
      end

      # Merges given configuration parameters with defined during initialization
      # and returns the result.
      #
      # @param [Hash] settings parameters to use.
      #
      # @option settings [String] :server Public blockchain API endpoint.
      # @option settings [Array<Hash>] :currencies List of currency hashes
      #   with :id,:base_factor,:options keys.
      #
      # @return [Hash] merged settings.
      def configure(settings = {})
        abstract_method
      end

      # Fetches blockchain block by calling API and builds block object
      # from response payload.
      #
      # @abstract
      #
      # @param block_number [Integer] the block number.
      # @return [Peatio::Block] the block object.
      def fetch_block!(block_number)
        abstract_method
      end

      # Fetches current blockchain height by calling API and returns it as number.
      #
      # @abstract
      #
      # @return [Integer] the current blockchain height.
      def latest_block_number
        abstract_method
      end

      # Defines if blockchain supports cash address format.
      #
      # @abstract
      # @deprecated Moved to features.
      #
      # @return [Boolean] is cash address format supported by blockchain.
      def supports_cash_addr_format?
        abstract_method
      end

      # Defines if blockchain transactions and addresses are case sensitive.
      #
      # @abstract
      # @deprecated Moved to features.
      #
      # @return [Boolean] blockchain transactions and addresses are case sensitive.
      def case_sensitive?
        abstract_method
      end

      private

      # Method for defining other methods as abstract.
      #
      # @raise [MethodNotImplemented]
      def abstract_method
        method_not_implemented
      end
    end
  end
end
