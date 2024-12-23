module KDL
  module V1
    class Value < ::KDL::Value
      def to_s
        return stringify_value unless type

        "(#{StringDumper.stringify_identifier type})#{stringify_value}"
      end

      class Int < ::KDL::Value::Int
      end

      class Float < ::KDL::Value::Float
        def stringify_value
          if value.nan? || value.infinite?
            warn "[WARNING] Attempting to serialize non-finite Float using KDL v1"
            return Null.stringify_value
          end
          super
        end
      end

      class Boolean < ::KDL::Value::Boolean
        def stringify_value
          value.to_s
        end
      end

      class String < ::KDL::Value::String
        def stringify_value
          StringDumper.call(value)
        end
      end

      class NullImpl < ::KDL::Value::NullImpl
        def stringify_value
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
end
