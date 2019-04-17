module Peatio
  module Wallet
    class Abstract
      def initialize(*)
        abstract_method
      end

      def configure(settings = {})
        abstract_method
      end

      def create_address(options = {})
        abstract_method
      end

      def create_transaction(withdrawal)
        abstract_method
      end

      private

      def abstract_method
        method_not_implemented
      end
    end
  end
end
