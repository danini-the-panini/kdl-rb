module KDL
  class Document
    attr_accessor :nodes
    
    def initialize(nodes)
      @nodes = nodes
    end

    def to_s
      @nodes.map(&:to_s).join("\n")
    end
    alias inspect to_s

    def ==(other)
      return false unless other.is_a?(Document)

      nodes == other.nodes
    end
  end
end
