# frozen_string_literal: true

module KDL
  module Types
    class Decimal < Value::Custom
      def self.call(value, type = 'decimal')
        return nil unless value.is_a? ::KDL::Value::String

        big_decimal = BigDecimal(value.value)
        new(big_decimal, type: type)
      end
    end
    MAPPING['decimal'] = Decimal
  end
end
