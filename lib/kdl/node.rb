module KDL
  class Node
    attr_accessor :name, :values, :kwargs, :children

    def initialize(name, values = [], kwargs = {}, children = [])
      @name = name
      @values = values
      @kwargs = kwargs
      @children = children
    end

    def to_s(level = 0)
      indent = '    ' * level
      s = "#{indent}#{name}"
      unless values.empty?
        s += " #{values.map(&:to_s).join(' ')}"
      end
      unless kwargs.empty?
        s += " #{kwargs.map { |k, v| "#{k}=#{v}" }.join(' ')}"
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
