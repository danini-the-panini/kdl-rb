module KDL
  class Node
    attr_accessor :name, :arguments, :properties, :children

    def initialize(name, arguments = [], properties = {}, children = nil)
      @name = name
      @arguments = arguments
      @properties = properties
      @children = children
    end

    def to_s(level = 0)
      indent = '    ' * level
      s = "#{indent}#{name}"
      unless arguments.empty?
        s += " #{arguments.map(&:to_s).join(' ')}"
      end
      unless properties.empty?
        s += " #{properties.map { |k, v| "#{k}=#{v}" }.join(' ')}"
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
  end
end
