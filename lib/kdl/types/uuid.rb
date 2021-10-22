module KDL
  module Types
    class UUID < Value
      RGX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/

      def self.call(value, type = 'uuid')
        return nil unless value.is_a? ::KDL::Value::String

        uuid = value.value.downcase
        raise ArgumentError, "`#{value.value}' is not a valid uuid" unless uuid.match?(RGX)

        new(uuid, type: type)
      end
    end
    MAPPING['uuid'] = UUID
  end
end
