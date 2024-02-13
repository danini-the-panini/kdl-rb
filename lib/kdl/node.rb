module KDL
  class Node
    attr_accessor :name, :arguments, :properties, :children, :type

    def initialize(name, arguments = [], properties = {}, children = [], type: nil)
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
      unless children.empty?
        s += " {\n"
        s += children.map { |c| "#{c.to_s(level + 1)}" }.join("\n")
        s += "\n#{indent}}"
      end
      s
    end

    def inspect(level = 0)
      indent = '    ' * level
      s = "#{indent}#{type ? "(#{type.inspect})" : ''}#{name.inspect}["
      unless arguments.empty?
        s += "#{arguments.map(&:inspect).join(' ')}"
      end
      unless properties.empty?
        s += " #{properties.map { |k, v| "#{k.inspect}=#{v.inspect}" }.join(' ')}"
      end
      s += "]"
      unless children.empty?
        s += " {\n"
        s += children.map { |c| "#{c.inspect(level + 1)}" }.join("\n")
        s += "\n#{indent}}"
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
      StringDumper.call(id.to_s)
    end
  end
end
