# NOTE: https://saveriomiroddi.github.io/Support-MySQL-native-JSON-data-type-in-Rails-4/

module ActiveRecord
  module Type
    class Json < Type::Value
      include Type::Mutable

      def type
        :json
      end

      def type_cast_for_database(value)
        case value
        when Hash
          value.to_json
        when ::String
          value
        else
          raise "Unsupported data/type for JSON conversion: #{value.class}"
        end
      end

      private

      def type_cast(value)
        case value
        when nil
          {}
        when ::String
          parsed_value = JSON.parse(value)

          if parsed_value.is_a?(Hash)
            parsed_value.deep_symbolize_keys
          else
            raise "Only Hashes are supported (or their string representation)"
          end
        when Hash
          value.deep_symbolize_keys
        else
          raise "Unsupported data/type for JSON conversion: #{value.class}"
        end
      end
    end
  end
end