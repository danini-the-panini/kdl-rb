require_relative './email/parser'

module KDL
  module Types
    class Email < Value
      attr_reader :local, :domain

      LOCAL_PART_CHARS = /[a-zA-Z0-9!#\$%&'*+\-\/=?\^_`{|}~]/
      LOCAL_PART_RGX = /^[a-zA-Z0-9!#\$%&'*+\-\/=?\^_`{|}~]{1,64}$/

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
  end
end
