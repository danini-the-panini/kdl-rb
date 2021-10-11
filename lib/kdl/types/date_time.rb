require 'time'

module KDL
  module Types
    class DateTime < Value
      def self.parse(string)
        value = ::Time.iso8601(string)
        new(value, type: 'date-time')
      end
    end
    MAPPING['date-time'] = DateTime

    class Time < Value
      # TODO: this is not a perfect ISO8601 time string
      REGEX = /^T?((?:2[0-3]|[01][0-9]):[0-5][0-9]:[0-5][0-9](?:\.[0-9]+)?(?:Z|[+-]\d\d:\d\d)?)$/

      def self.parse(string)
        match = REGEX.match(string)
        raise ArgumentError, 'invalid time' if match.nil?

        value = ::Time.iso8601("#{::Date.today.iso8601}T#{match[1]}")
        new(value, type: 'time')
      end
    end
    MAPPING['time'] = Time

    class Date < Value
      def self.parse(string)
        value = ::Date.iso8601(string)
        new(value, type: 'date')
      end
    end
    MAPPING['date'] = Date
  end
end
