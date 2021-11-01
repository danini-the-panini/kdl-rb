require 'simpleidn'

module KDL
  module Types
    class Hostname < Value
      PART_RGX = /^[a-z0-9_\-]{1,63}$/i

      def self.call(value, type = 'hostname')
        raise ArgumentError, "invalid hostname #{value}" unless valid_hostname?(value.value)

        new(value.value, type: type)
      end

      def self.valid_hostname_part?(part)
        return false if part.empty?
        return false if part.start_with?('-') || part.end_with?('-')

        part =~ PART_RGX
      end

      def self.valid_hostname?(hostname)
        hostname.split('.').all? { |part| valid_hostname_part?(part) }
      end
    end
    MAPPING['hostname'] = Hostname

    class IDNHostname < Hostname
      attr_reader :ascii_value

      def initialize(value, ascii_value:, **kwargs)
        super(value, **kwargs)
        @ascii_value = ascii_value
      end

      def self.call(value, type = 'idn-hostname')
        parts = value.value.split('.')
        raise ArgumentError, "invalid hostname #{value}" unless valid_hostname?(value.value)

        new(SimpleIDN.to_unicode(value.value), type: type, ascii_value: value.value)
      end
    end
    MAPPING['idn-hostname'] = IDNHostname
  end
end
