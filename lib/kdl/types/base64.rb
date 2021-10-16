require 'base64'

module KDL
  module Types
    class Base64 < Value
      def self.parse(string)
        value = ::Base64.decode64(string)
        new(value, type: 'base64')
      end
    end
    MAPPING['base64'] = Base64
  end
end
