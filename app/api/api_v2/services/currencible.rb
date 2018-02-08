module APIv2
  module Services
    module Currencible
      def self.codes(args={})
        return [] unless ActiveRecord::Base.connection.table_exists?('currencies')
        return Currency.codes.map(&:upcase) if args[:upcase].present?
        return Currency.codes.map(&:downcase) if args[:downcase].present?
        return Currency.codes.map(&:upcase) + Currency.codes.map(&:downcase) if args[:bothcase].present?

        Currency.codes
      end
    end
  end
end
