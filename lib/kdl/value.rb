module KDL
  class Value
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def to_s
      value.to_s
    end
    alias inspect to_s

    class Int < Value
      def ==(other)
        other.is_a?(Int) && value == other.value
      end
    end

    class Float < Value
      def ==(other)
        other.is_a?(Float) && value == other.value
      end
    end

    class Boolean < Value
      def ==(other)
        other.is_a?(Boolean) && value == other.value
      end
    end

    class String < Value
      def to_s
        value.inspect
      end
      alias inspect to_s

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
