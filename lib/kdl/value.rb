module KDL
  class Value
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def to_s
      value.to_s
    end

    def ==(other)
      return false unless other.is_a?(Value)

      value == other.value
    end

    class Int < Value
    end

    class Float < Value
    end

    class Boolean < Value
    end

    class String < Value
      def to_s
        value.inspect
      end
    end

    class NullImpl < Value
      def initialize
        super(nil)
      end

      def to_s
        "null"
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
