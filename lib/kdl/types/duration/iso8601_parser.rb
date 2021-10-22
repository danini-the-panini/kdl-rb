# Shamelessly borrowed from https://github.com/rails/rails/tree/main/activesupport
#
# Copyright (c) 2005-2021 David Heinemeier Hansson

# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'strscan'

module KDL
  module Types
    class Duration < Value
      # Parses a string formatted according to ISO 8601 Duration into the hash.
      #
      # See {ISO 8601}[https://en.wikipedia.org/wiki/ISO_8601#Durations] for more information.
      #
      # This parser allows negative parts to be present in pattern.
      class ISO8601Parser # :nodoc:
        class ParsingError < ::ArgumentError; end

        PERIOD_OR_COMMA = /\.|,/
        PERIOD = '.'
        COMMA = ','

        SIGN_MARKER = /\A-|\+|/
        DATE_MARKER = /P/
        TIME_MARKER = /T/
        DATE_COMPONENT = /(-?\d+(?:[.,]\d+)?)(Y|M|D|W)/
        TIME_COMPONENT = /(-?\d+(?:[.,]\d+)?)(H|M|S)/

        DATE_TO_PART = { 'Y' => :years, 'M' => :months, 'W' => :weeks, 'D' => :days }
        TIME_TO_PART = { 'H' => :hours, 'M' => :minutes, 'S' => :seconds }

        DATE_COMPONENTS = %i[years months days]
        TIME_COMPONENTS = %i[hours minutes seconds]

        attr_reader :parts, :scanner
        attr_accessor :mode, :sign

        def initialize(string)
          @scanner = StringScanner.new(string)
          @parts = {}
          @mode = :start
          @sign = 1
        end

        def parse!
          until finished?
            case mode
            when :start
              if scan(SIGN_MARKER)
                self.sign = scanner.matched == '-' ? -1 : 1
                self.mode = :sign
              else
                raise_parsing_error
              end

            when :sign
              if scan(DATE_MARKER)
                self.mode = :date
              else
                raise_parsing_error
              end

            when :date
              if scan(TIME_MARKER)
                self.mode = :time
              elsif scan(DATE_COMPONENT)
                parts[DATE_TO_PART[scanner[2]]] = number * sign
              else
                raise_parsing_error
              end

            when :time
              if scan(TIME_COMPONENT)
                parts[TIME_TO_PART[scanner[2]]] = number * sign
              else
                raise_parsing_error
              end

            end
          end

          validate!
          parts
        end

        private

        def finished?
          scanner.eos?
        end

        # Parses number which can be a float with either comma or period.
        def number
          (PERIOD_OR_COMMA =~ scanner[1]) ? scanner[1].tr(COMMA, PERIOD).to_f : scanner[1].to_i
        end

        def scan(pattern)
          scanner.scan(pattern)
        end

        def raise_parsing_error(reason = nil)
          raise ParsingError, "Invalid ISO 8601 duration: #{scanner.string.inspect} #{reason}".strip
        end

        # Checks for various semantic errors as stated in ISO 8601 standard.
        def validate!
          raise_parsing_error('is empty duration') if parts.empty?

          # Mixing any of Y, M, D with W is invalid.
          if parts.key?(:weeks) && (parts.keys & DATE_COMPONENTS).any?
            raise_parsing_error('mixing weeks with other date parts not allowed')
          end

          # Specifying an empty T part is invalid.
          if mode == :time && (parts.keys & TIME_COMPONENTS).empty?
            raise_parsing_error('time part marker is present but time part is empty')
          end

          fractions = parts.values.reject(&:zero?).select { |a| (a % 1) != 0 }
          unless fractions.empty? || (fractions.size == 1 && fractions.last == @parts.values.reject(&:zero?).last)
            raise_parsing_error '(only last part can be fractional)'
          end

          true
        end
      end
    end
  end
end
