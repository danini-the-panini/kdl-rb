module KDL
  module Types
    class Regex < Value
      def self.parse(string)
        value = ::Regexp.new(string)
        new(value, type: 'regex')
      end
    end
    MAPPING['regex'] = Regex
  end
end
