# frozen_string_literal: true

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

        unless result.is_a?(::KDL::Value::Custom)
          raise ArgumentError, "expected parser to return an instance of ::KDL::Value::Custom, got `#{result.class}'"
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

    def version
      2
    end

    def to_v2
      self
    end

    def method_missing(name, *args, **kwargs, &block)
      value.public_send(name, *args, **kwargs, &block)
    end

    def respond_to_missing?(name, include_all = false)
      value.respond_to?(name, include_all)
    end

    class Int < Value
      def to_v1
        V1::Value::Int.new(value, format:, type:)
      end
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
        s = +''
        s << '-' if sign.negative?
        s << "#{digits[0]}.#{digits[1..-1]}"
        s << "E#{exponent.negative? ? '' : '+'}#{exponent - 1}"
        s
      end

      def to_v1
        if value.nan? || value.infinite?
          warn "[WARNING] Converting non-finite Float to KDL v1"
        end
        V1::Value::Float.new(value, format:, type:)
      end
    end

    class Boolean < Value
      def stringify_value
        "##{value}"
      end

      def to_v1
        V1::Value::Boolean.new(value, format:, type:)
      end
    end

    class String < Value
      def stringify_value
        StringDumper.call(value)
      end

      def to_v1
        V1::Value::String.new(value, format:, type:)
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

      def to_v1
        type ? V1::Value::NullImpl.new(type:) : V1::Value::Null
      end
    end
    Null = NullImpl.new

    class Custom < Value
      attr_reader :oriinal_value

      def self.call(value, type)
        new(value, type:)
      end

      def version
        nil
      end

      def to_v1
        self
      end

      def to_v2
        self
      end
    end

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
