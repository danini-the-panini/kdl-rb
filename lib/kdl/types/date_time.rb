# frozen_string_literal: true

require 'time'

module KDL
  module Types
    class DateTime < Value::Custom
      def self.call(value, type = 'date-time')
        return nil unless value.is_a? ::KDL::Value::String

        time = ::Time.iso8601(value.value)
        new(time, type: type)
      end
    end
    MAPPING['date-time'] = DateTime

    class Time < Value::Custom
      # TODO: this is not a perfect ISO8601 time string
      REGEX = /^T?((?:2[0-3]|[01][0-9]):[0-5][0-9]:[0-5][0-9](?:\.[0-9]+)?(?:Z|[+-]\d\d:\d\d)?)$/

      def self.call(value, type = 'time')
        return nil unless value.is_a? ::KDL::Value::String

        match = REGEX.match(value.value)
        raise ArgumentError, 'invalid time' if match.nil?

        time = ::Time.iso8601("#{::Date.today.iso8601}T#{match[1]}")
        new(time, type: type)
      end
    end
    MAPPING['time'] = Time

    class Date < Value::Custom
      def self.call(value, type = 'date')
        return nil unless value.is_a? ::KDL::Value::String

        date = ::Date.iso8601(value.value)
        new(date, type: type)
      end
    end
    MAPPING['date'] = Date
  end
end
