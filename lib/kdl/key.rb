module KDL
  class Key
    attr_reader :name, :quoted

    def initialize(name, quoted: false)
      @name = name
      @quoted = quoted
    end

    def to_s
      if quoted
        name.inspect
      else
        name.to_s
      end
    end

    def ==(other)
      return false unless other.is_a?(Key)

      name == other.name
    end
    alias eql? ==

    def hash
      name.hash
    end
  end
end
