module KDL
  module Types
    class IP < Value::Custom
      def self.call(value, type = ip_type)
        return nil unless value.is_a? ::KDL::Value::String

        ip = ::IPAddr.new(value.value)
        raise ArgumentError, "invalid #{ip_type} address" unless valid_ip?(ip)

        new(ip, type: type)
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
