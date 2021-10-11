require 'kdl/types/currency/iso4217_currencies'

module KDL
  module Types
    class Currency < Value
      attr_reader :numeric_code, :minor_unit, :name

      def initialize(value, format: nil, type: 'currency')
        super
        @numeric = value.fetch(:numeric, nil)
        @minor_unit = value.fetch(:minor_unit, nil)
        @name = value.fetch(:name, '')
      end

      def self.parse(string)
        currency = CURRENCIES[string.upcase]
        raise ArgumentError, 'invalid currency' if currency.nil?

        new(currency, type: 'currency')
      end
    end
    MAPPING['currency'] = Currency
  end
end
