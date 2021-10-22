module KDL
  class Node
    attr_accessor :name, :arguments, :properties, :children, :type

    def initialize(name, arguments = [], properties = {}, children = nil, type: nil)
      @name = name
      @arguments = arguments
      @properties = properties
      @children = children
      @type = type
    end

    def to_s(level = 0)
      indent = '    ' * level
      s = "#{indent}#{type ? "(#{id_to_s type})" : ''}#{id_to_s name}"
      unless arguments.empty?
        s += " #{arguments.map(&:to_s).join(' ')}"
      end
      unless properties.empty?
        s += " #{properties.map { |k, v| "#{id_to_s k}=#{v}" }.join(' ')}"
      end
      unless children.nil?
        s += " {\n"
        unless children.empty?
          s += children.map { |c| "#{c.to_s(level + 1)}\n" }.join("\n")
        end
        s += "#{indent}}"
      end
      s
    end

    def ==(other)
      return false unless other.is_a?(Node)

      name       == other.name       &&
      arguments  == other.arguments  &&
      properties == other.properties &&
      children   == other.children
    end

    def as_type(type, parser = nil)
      if parser.nil?
        @type = type
        self
      else
        result = parser.call(self, type)

        return self.as_type(type) if result.nil?

        unless result.is_a?(::KDL::Node)
          raise ArgumentError, "expected parser to return an instance of ::KDL::Node, got `#{result.class}'"
        end

        result
      end
    end

    private

    def id_to_s(id)
      StringDumper.stringify_identifier(id)
    end
  end
end
