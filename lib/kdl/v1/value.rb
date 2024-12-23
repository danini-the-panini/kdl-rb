module KDL
  module V1
    class Value < ::KDL::Value
      module Methods
        def to_s
          return stringify_value unless type

          "(#{StringDumper.stringify_identifier type})#{stringify_value}"
        end

        def ==(other)
          return self == other.value if other.is_a?(self.class.superclass)

          value == other
        end

        def version
          1
        end

        def to_v1
          self
        end

        def to_v2
          self.class.superclass.new(value, format:, type:)
        end
      end

      include Methods

      class Int < ::KDL::Value::Int
        include Methods
      end

      class Float < ::KDL::Value::Float
        include Methods

        def stringify_value
          if value.nan? || value.infinite?
            warn "[WARNING] Attempting to serialize non-finite Float using KDL v1"
            return Null.stringify_value
          end
          super
        end
      end

      class Boolean < ::KDL::Value::Boolean
        include Methods

        def stringify_value
          value.to_s
        end
      end

      class String < ::KDL::Value::String
        include Methods

        def stringify_value
          StringDumper.call(value)
        end
      end

      class NullImpl < ::KDL::Value::NullImpl
        include Methods

        def stringify_value
          "null"
        end

        def to_v2
          type ? ::KDL::Value::NullImpl.new(type:) : ::KDL::Value::Null
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
