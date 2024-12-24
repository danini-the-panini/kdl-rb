require_relative './email/parser'

module KDL
  module Types
    class Email < Value::Custom
      attr_reader :local, :domain

      def initialize(value, local:, domain:, **kwargs)
        super(value, **kwargs)
        @local = local
        @domain = domain
      end

      def self.call(value, type = 'email')
        return nil unless value.is_a? ::KDL::Value::String

        local, domain = Parser.new(value.value).parse

        new(value.value, type: type, local: local, domain: domain)
      end

    end
    MAPPING['email'] = Email

    class IDNEmail < Email
      attr_reader :unicode_domain

      def initialize(value, unicode_domain:, **kwargs)
        super(value, **kwargs)
        @unicode_domain = unicode_domain
      end

      def self.call(value, type = 'email')
        return nil unless value.is_a? ::KDL::Value::String

        local, domain, unicode_domain = Email::Parser.new(value.value, idn: true).parse

        new("#{local}@#{domain}", type: type, local: local, domain: domain, unicode_domain: unicode_domain)
      end

      def unicode_value
        "#{local}@#{unicode_domain}"
      end
    end
    MAPPING['idn-email'] = IDNEmail
  end
end
