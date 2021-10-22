require 'kdl/types/duration/iso8601_parser'

module KDL
  module Types
    class Duration < Value
      attr_reader :years, :months, :weeks, :days, :hours, :minutes, :seconds

      def initialize(parts = {}, format: nil, type: 'duration')
        super
        @years = parts.fetch(:years, 0)
        @months = parts.fetch(:months, 0)
        @weeks = parts.fetch(:weeks, 0)
        @days = parts.fetch(:days, 0)
        @hours = parts.fetch(:hours, 0)
        @minutes = parts.fetch(:minutes, 0)
        @seconds = parts.fetch(:seconds, 0)
      end

      def self.call(value, type = 'duration')
        return nil unless value.is_a? ::KDL::Value::String

        parts = ISO8601Parser.new(value.value).parse!
        new(parts, type: type)
      end
    end
    MAPPING['duration'] = Duration
  end
end
