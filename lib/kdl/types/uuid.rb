module KDL
  module Types
    class UUID < Value
      RGX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/

      def self.parse(string)
        value = string.downcase
        raise ArgumentError, "`#{string}' is not a valid uuid" unless value.match?(RGX)

        new(value, type: 'uuid')
      end
    end
    MAPPING['uuid'] = UUID
  end
end
