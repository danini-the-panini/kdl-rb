module KDL
  class Node
    class Custom < Node
      def self.call(node, type)
        new(node.name, arguments: node.arguments, properties: node.properties, children: node.children, type:)
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

    include Enumerable

    attr_accessor :name, :arguments, :properties, :children, :type

    def initialize(name, _args = [], _props = {}, _children = [],
      arguments: _args,
      properties: _props,
      children: _children,
      type: nil
    )
      @name = name
      @arguments = arguments
      @properties = properties.transform_keys(&:to_s)
      @children = children
      @type = type
    end

    def [](key)
      case key
      when Integer
        arguments[key]&.value
      when String, Symbol
        properties[key.to_s]&.value
      else
        raise ArgumentError, "node can only be indexed by Integer/String"
      end
    end

    def child(key)
      case key
      when Integer
        children[key]
      when String, Symbol
        children.find { _1.name == key.to_s }
      else
        raise ArgumentError, "node can only be indexed by Integer/String"
      end
    end

    def arg(key)
      child(key)&.arguments&.first&.value
    end

    def args(key)
      child(key)&.arguments&.map(&:value)
    end

    def each_arg(key, &block)
      args(key)&.each(&block)
    end

    def dash_vals(key)
      child(key)
        &.children
        &.select { _1.name == "-" }
        &.map { _1.arguments.first&.value }
    end

    def each_dash_val(key, &block)
      dash_vals(key)&.each(&block)
    end

    def each(&block)
      children.each(&block)
    end

    def <=>(other)
      name <=> other.name
    end

    def to_s(level = 0, m = :to_s)
      indent = '    ' * level
      s = "#{indent}#{type ? "(#{id_to_s type, m })" : ''}#{id_to_s name, m}"
      unless arguments.empty?
        s += " #{arguments.map(&m).join(' ')}"
      end
      unless properties.empty?
        s += " #{properties.map { |k, v| "#{id_to_s k, m}=#{v.public_send(m)}" }.join(' ')}"
      end
      unless children.empty?
        s += " {\n"
        s += children.map { |c| "#{c.public_send(m, level + 1)}" }.join("\n")
        s += "\n#{indent}}"
      end
      s
    end

    def inspect(level = 0)
      to_s(level, :inspect)
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

        unless result.is_a?(::KDL::Node::Custom)
          raise ArgumentError, "expected parser to return an instance of ::KDL::Node::Custom, got `#{result.class}'"
        end

        result
      end
    end

    def version
      2
    end

    def to_v2
      self
    end

    def to_v1
      ::KDL::V1::Node.new(name,
        arguments: arguments.map(&:to_v1),
        properties: properties.transform_values(&:to_v1),
        children: children.map(&:to_v1),
        type: type
      )
    end

    private

    def id_to_s(id, m = :to_s)
      return id.public_send(m) unless m == :to_s

      StringDumper.call(id.to_s)
    end
  end
end
