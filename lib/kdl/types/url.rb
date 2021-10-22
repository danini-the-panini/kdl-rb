module KDL
  module Types
    class URL < Value
      def self.call(value, type = 'url')
        return nil unless value.is_a? ::KDL::Value::String

        uri = URI(value.value)
        new(uri, type: type)
      end
    end
    MAPPING['url'] = URL
  end
end
