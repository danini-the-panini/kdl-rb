module KDL
  class Value
    attr_reader :value, :format

    def initialize(value, format: nil)
      @value = value
      @format = format
    end

    def to_s
      return format % value if format

      value.to_s
    end

    class Int < Value
      def ==(other)
        other.is_a?(Int) && value == other.value
      end
    end

    class Float < Value
      def ==(other)
        other.is_a?(Float) && value == other.value
      end

      def to_s
        return super unless value.is_a?(BigDecimal)

        sign, digits, _, exponent = value.split
        s = sign.negative? ? '-' : ''
        s += "#{digits[0]}.#{digits[1..-1]}"
        s += "E#{exponent.negative? ? '' : '+'}#{exponent - 1}"
        s
      end
    end

    class Boolean < Value
      def ==(other)
        other.is_a?(Boolean) && value == other.value
      end
    end

    class String < Value
      def to_s
        StringDumper.call(value)
      end

      def ==(other)
        other.is_a?(String) && value == other.value
      end
    end

    class NullImpl < Value
      def initialize
        super(nil)
      end

      def to_s
        "null"
      end
      alias inspect to_s

      def ==(other)
        other.is_a?(NullImpl)
      end
    end
    Null = NullImpl.new

    def self.from(value)
      case value
      when ::String then String.new(value)
      when Integer then Int.new(value)
      when ::Float then Float.new(value)
      when TrueClass, FalseClass then Boolean.new(value)
      when NilClass then Null
      else raise Error("Unsupported value type: #{value.class}")
      end
    end
  end
end
