require 'simpleidn'

module KDL
  module Types
    class Hostname < Value::Custom
      class Validator
        PART_RGX = /^[a-z0-9_][a-z0-9_\-]{0,62}$/i

        attr_reader :string
        alias ascii string
        alias unicode string

        def initialize(string)
          @string = string
        end

        def valid?
          return false if @string.length > 253

          @string.split('.').all? { |x| valid_part?(x) }
        end

        private

        def valid_part?(part)
          return false if part.empty?
          return false if part.start_with?('-') || part.end_with?('-')

          part =~ PART_RGX
        end
      end
    end

    class IDNHostname < Hostname
      class Validator < Hostname::Validator
        attr_reader :unicode

        def initialize(string)
          is_ascii = string.split('.').any? { |x| x.start_with?('xn--') }
          if is_ascii
            super(string)
            @unicode = SimpleIDN.to_unicode(string)
          else
            super(SimpleIDN.to_ascii(string))
            @unicode = string
          end
        end
      end
    end
  end
end
