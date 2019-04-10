module Peatio
  module BlockchainAPI
    Error = Class.new(StandardError)
    DuplicatedAdapterError = Class.new(Error)
    NotRegisteredAdapterError = Class.new(Error)

    class << self
      def register(name, instance)
        name = name.to_sym
        raise DuplicatedAdapterError if adapters.key?(name)
        adapters[name] = instance
      end

      def adapter_for(name)
        adapters.fetch(name.to_sym) { raise NotRegisteredAdapterError }
      end

      def adapters
        @adapters ||= {}
      end

      def adapters=(h)
        @adapters = h
      end
    end
  end
end
