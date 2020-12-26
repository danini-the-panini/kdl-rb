module KDL
  class Document
    attr_accessor :nodes
    
    def initialize(nodes)
      @nodes = nodes
    end

    def to_s
      @nodes.map(&:to_s).join("\n")
    end
  end
end
