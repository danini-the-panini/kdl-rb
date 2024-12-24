module KDL
  module Types
    class URLReference < Value::Custom
      def self.call(value, type = 'url-reference')
        return nil unless value.is_a? ::KDL::Value::String

        uri = parse_url(value.value)
        new(uri, type: type)
      end

      def self.parse_url(string)
        URI.parse(string)
      end
    end
    MAPPING['url-reference'] = URLReference

    class URL < URLReference
      def self.call(value, type = 'url')
        super(value, type)
      end

      def self.parse_url(string)
        super.tap do |uri|
          raise 'invalid URL' if uri.scheme.nil?
        end
      end
    end
    MAPPING['url'] = URL
  end
end
