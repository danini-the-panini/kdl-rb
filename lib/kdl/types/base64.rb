require 'base64'

module KDL
  module Types
    class Base64 < Value
      RGX = /^[A-Za-z0-9+\/=]+$/.freeze

      def self.call(value, type = 'base64')
        return nil unless value.is_a? ::KDL::Value::String

        unless RGX.match?(value.value)
            raise ArgumentError, "invalid base64: #{value.value}"
      end

        data = ::Base64.decode64(value.value)
        new(data, type: type)
      end
    end
    MAPPING['base64'] = Base64
  end
end
