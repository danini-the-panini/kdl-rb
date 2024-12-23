module KDL
  class Value
    attr_reader :value, :format, :type

    def initialize(value, format: nil, type: nil)
      @value = value
      @format = format
      @type = type
    end

    def as_type(type, parser = nil)
      if parser.nil?
        self.class.new(value, format: format, type: type)
      else
        result = parser.call(self, type)
        return self.as_type(type) if result.nil?

        unless result.is_a?(::KDL::Value)
          raise ArgumentError, "expected parser to return an instance of ::KDL::Value, got `#{result.class}'"
        end

        result
      end
    end

    def ==(other)
      return self == other.value if other.is_a?(self.class)

      value == other
    end

    def to_s
      return stringify_value unless type

      "(#{StringDumper.call type})#{stringify_value}"
    end

    def inspect
      return value.inspect unless type

      "(#{type.inspect})#{value.inspect}"
    end

    def stringify_value
      return format % value if format

      value.to_s
    end

    def method_missing(name, *args, **kwargs, &block)
      value.public_send(name, *args, **kwargs, &block)
    end

    def respond_to_missing?(name, include_all = false)
      value.respond_to?(name, include_all)
    end

    class Int < Value
    end

    class Float < Value
      def ==(other)
        return self == other.value if other.is_a?(Float)
        return other.nan? if value.nan?

        value == other
      end

      def stringify_value
        return '#nan'  if value.nan?
        return '#inf'  if value == ::Float::INFINITY
        return '#-inf' if value == -::Float::INFINITY
        return super.upcase unless value.is_a?(BigDecimal)

        sign, digits, _, exponent = value.split
        s = sign.negative? ? '-' : ''
        s += "#{digits[0]}.#{digits[1..-1]}"
        s += "E#{exponent.negative? ? '' : '+'}#{exponent - 1}"
        s
      end
    end

    class Boolean < Value
      def stringify_value
        "##{value}"
      end
    end

    class String < Value
      def stringify_value
        StringDumper.call(value)
      end
    end

    class NullImpl < Value
      def initialize(_=nil, format: nil, type: nil)
        super(nil, type: type)
      end

      def stringify_value
        "#null"
      end

      def ==(other)
        other.is_a?(NullImpl) || other.nil?
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
