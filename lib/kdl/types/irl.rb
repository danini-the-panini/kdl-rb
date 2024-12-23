require_relative './irl/parser'

module KDL
  module Types
    class IRLReference < Value::Custom
      attr_reader :unicode_value,
                  :unicode_domain,
                  :unicode_path,
                  :unicode_search,
                  :unicode_hash

      def initialize(value, unicode_value:, unicode_domain:, unicode_path:, unicode_search:, unicode_hash:, **kwargs)
        super(value, **kwargs)
        @unicode_value = unicode_value
        @unicode_domain = unicode_domain
        @unicode_path = unicode_path
        @unicode_search = unicode_search
        @unicode_hash = unicode_hash
      end

      def self.call(value, type = 'irl-reference')
        return nil unless value.is_a? ::KDL::Value::String

        ascii_value, params = parser(value.value).parse

        new(URI.parse(ascii_value), type: type, **params)
      end

      def self.parser(string)
        IRLReference::Parser.new(string)
      end
    end
    MAPPING['irl-reference'] = IRLReference

    class IRL < IRLReference
      def self.call(value, type = 'irl')
        super(value, type)
      end

      def self.parser(string)
        IRL::Parser.new(string)
      end
    end
    MAPPING['irl'] = IRL
  end
end
