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
      #
      # @return [Boolean] is cash address format supported by blockchain.
      def supports_cash_addr_format?
        abstract_method
      end

      # Defines if blockchain transactions and addresses are case sensitive.
      #
      # @abstract
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
