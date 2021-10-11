require 'kdl/types/country/iso3166_countries'

module KDL
  module Types
    class Country < Value
      attr_reader :name, :alpha2, :alpha3, :numeric_code

      def initialize(value, format: nil, type: 'country-3')
        super
        @name = value.fetch(:name, '')
        @alpha3 = value.fetch(:alpha3, nil)
        @alpha2 = value.fetch(:alpha2, nil)
        @numeric_code = value.fetch(:numeric_code, nil)
      end

      def self.parse(string)
        country = COUNTRIES3[string.upcase]
        raise ArgumentError, 'invalid country-3' if country.nil?

        new(country, type: 'country-3')
      end

    end
    Country3 = Country
    MAPPING['country-3'] = Country3

    class Country2 < Country
      def initialize(value, format: nil, type: 'country-2')
        super
      end

      def self.parse(string)
        country = COUNTRIES2[string.upcase]
        raise ArgumentError, 'invalid country-3' if country.nil?

        new(country, type: 'country-2')
      end
    end
    MAPPING['country-2'] = Country2

    # TODO: country-subdivision??
  end
end
