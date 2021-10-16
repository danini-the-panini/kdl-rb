module KDL
  module Types
    class IP < Value
      def self.parse(string)
        value = IPAddr.new(string)
        raise ArgumentError, "invalid #{ip_type} address" unless valid_ip?(value)

        new(value, type: ip_type)
      end

      def self.valid_ip?(ip)
        ip.__send__(:"#{ip_type}?")
      end
    end

    class IPV4 < IP
      def self.ip_type
        'ipv4'
      end
    end
    MAPPING['ipv4'] = IPV4

    class IPV6 < IP
      def self.ip_type
        'ipv6'
      end
    end
    MAPPING['ipv6'] = IPV6
  end
end
