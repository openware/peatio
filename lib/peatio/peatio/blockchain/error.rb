module Peatio
  module Blockchain
    Error = Class.new(StandardError)

    class ClientError < Error

      attr_reader :wrapped_ex

      def initialize(ex_or_string)
        @wrapped_ex = nil

        if ex_or_string.respond_to?(:backtrace)
          super(ex_or_string.message)
          @wrapped_exception = ex_or_string
        else
          super(ex_or_string.to_s)
        end
      end
    end

    class MissingSettingError < Error
      def initialize(key)
        super "#{key.capitalize} setting is missing"
      end
    end

    class UnavailableAddressBalanceError < Error
      def initialize(address)
        @address = address
      end

      def message
        "Unable to load #{@address} balance"
      end
    end
  end
end
