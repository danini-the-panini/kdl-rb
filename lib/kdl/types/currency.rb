# frozen_string_literal: true

require 'kdl/types/currency/iso4217_currencies'

module KDL
  module Types
    class Currency < Value::Custom
      attr_reader :numeric_code, :minor_unit, :name

      def initialize(value, format: nil, type: 'currency')
        super
        @numeric = value.fetch(:numeric, nil)
        @minor_unit = value.fetch(:minor_unit, nil)
        @name = value.fetch(:name, '')
      end

      def self.call(value, type = 'currency')
        return nil unless value.is_a? ::KDL::Value::String

        currency = CURRENCIES[value.value.upcase]
        raise ArgumentError, 'invalid currency' if currency.nil?

        new(currency, type: type)
      end
    end
    MAPPING['currency'] = Currency
  end
end
