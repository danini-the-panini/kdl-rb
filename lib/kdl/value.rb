module KDL
  class Value
    attr_reader :value, :format, :type

    def initialize(value, format: nil, type: nil)
      @value = value
      @format = format
      @type = type
    end

    def as_type(type)
      self.class.new(value, format: format, type: type)
    end

    def to_s
      return stringify_value unless type

      "(#{type})#{stringify_value}"
    end

    def stringify_value
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

      def stringify_value
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
      def stringify_value
        StringDumper.call(value)
      end

      def ==(other)
        other.is_a?(String) && value == other.value
      end
    end

    class NullImpl < Value
      def initialize(_=nil, format: nil, type: nil)
        super(nil, type: type)
      end

      def stringify_value
        "null"
      end

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
