module KDL
  class Document
    include Enumerable

    attr_accessor :nodes

    def initialize(nodes)
      @nodes = nodes
    end

    def [](key)
      case key
      when Integer
        nodes[key]
      when String, Symbol
        nodes.find { _1.name == key.to_s }
      else
        raise ArgumentError, "document can only be indexed by Integer, String, or Symbol"
      end
    end

    def arg(key)
      self[key]&.arguments&.first&.value
    end

    def args(key)
      self[key]&.arguments&.map(&:value)
    end

    def each_arg(key, &block)
      args(key)&.each(&block)
    end

    def dash_vals(key)
      self[key]
        &.children
        &.select { _1.name == "-" }
        &.map { _1.arguments.first&.value }
    end

    def each_dash_val(key, &block)
      dash_vals(key)&.each(&block)
    end

    def each(&block)
      nodes.each(&block)
    end

    def to_s
      nodes.map(&:to_s).join("\n") + "\n"
    end

    def inspect
      nodes.map(&:inspect).join("\n") + "\n"
    end

    def ==(other)
      return false unless other.is_a?(Document)

      nodes == other.nodes
    end

    def version
      2
    end

    def to_v2
      self
    end

    def to_v1
      KDL::V1::Document.new(nodes.map(&:to_v1))
    end
  end
end
