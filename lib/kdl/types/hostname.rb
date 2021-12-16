require_relative './hostname/validator'

module KDL
  module Types
    class Hostname < Value
      def self.call(value, type = 'hostname')
        return nil unless value.is_a? ::KDL::Value::String

        validator = Validator.new(value.value)
        raise ArgumentError, "invalid hostname #{value}" unless validator.valid?

        new(value.value, type: type)
      end
    end
    MAPPING['hostname'] = Hostname

    class IDNHostname < Hostname
      attr_reader :unicode_value

      def initialize(value, unicode_value:, **kwargs)
        super(value, **kwargs)
        @unicode_value = unicode_value
      end

      def self.call(value, type = 'idn-hostname')
        return nil unless value.is_a? ::KDL::Value::String

        validator = Validator.new(value.value)
        raise ArgumentError, "invalid hostname #{value}" unless validator.valid?

        new(validator.ascii, type: type, unicode_value: validator.unicode)
      end
    end
    MAPPING['idn-hostname'] = IDNHostname
  end
end
