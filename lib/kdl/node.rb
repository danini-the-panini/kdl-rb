module KDL
  class Node
    attr_accessor :name, :arguments, :properties, :children

    def initialize(name, arguments = [], properties = {}, children = [])
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
      unless children.empty?
        s += " {\n"
        s += children.map { |c| c.to_s(level + 1) }.join("\n")
        s += "\n#{indent}}"
      end
      s
    end
  end
end
