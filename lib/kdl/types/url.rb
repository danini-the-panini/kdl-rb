module KDL
  module Types
    class URL < Value
      def self.parse(string)
        value = URI(string)
        new(value, type: 'url')
      end
    end
    MAPPING['url'] = URL
  end
end
