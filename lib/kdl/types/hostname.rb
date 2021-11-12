require 'simpleidn'

module KDL
  module Types
    class Hostname < Value
      PART_RGX = /^[a-z0-9_][a-z0-9_\-]{0,62}$/i

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
        return false if hostname.length > 253

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
        is_ascii = value.value.split('.').any? { |x| x.start_with?('xn--') }

        if is_ascii
          unicode = SimpleIDN.to_unicode(value.value)
          ascii = value.value
        else
          ascii = SimpleIDN.to_ascii(value.value)
          unicode = value.value
        end
        raise ArgumentError, "invalid hostname #{value}" unless valid_hostname?(ascii)

        new(unicode, type: type, ascii_value: ascii)
      end
    end
    MAPPING['idn-hostname'] = IDNHostname
  end
end
