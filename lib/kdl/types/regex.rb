# frozen_string_literal: true

module KDL
  module Types
    class Regex < Value::Custom
      def self.call(value, type = 'regex')
        return nil unless value.is_a? ::KDL::Value::String

        regex = ::Regexp.new(value.value)
        new(regex, type: type)
      end
    end
    MAPPING['regex'] = Regex
  end
end
