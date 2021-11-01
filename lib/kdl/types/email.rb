require_relative './email/parser'

module KDL
  module Types
    class Email < Value
      attr_reader :local, :domain

      def initialize(value, local:, domain:, **kwargs)
        super(value, **kwargs)
        @local = local
        @domain = domain
      end

      def self.call(value, type = 'email')
        local, domain = Parser.new(value.value).parse

        new(value.value, type: type, local: local, domain: domain)
      end

    end
    MAPPING['email'] = Email

    class IDNEmail < Email
      attr_reader :ascii_domain

      def initialize(value, ascii_domain:, **kwargs)
        super(value, **kwargs)
        @ascii_domain = ascii_domain
      end

      def self.call(value, type = 'email')
        local, domain, ascii_domain = Email::Parser.new(value.value, idn: true).parse

        new(value.value, type: type, local: local, domain: domain, ascii_domain: ascii_domain)
      end
    end
    MAPPING['idn-email'] = IDNEmail
  end
end
