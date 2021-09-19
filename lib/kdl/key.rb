module KDL
  class Key
    attr_reader :name, :quoted

    def initialize(name, quoted: false)
      @name = name
      @quoted = quoted
    end

    def to_s
      if bare_identifier?
        name
      else
        StringDumper.call(name)
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

    private

    def bare_identifier?
      escape_chars = '\\\/(){}<>;\[\]=,"'
      name =~ /^([^0-9\-+\s#{escape_chars}][^\s#{escape_chars}]*|[\-+](?!true|false|null)[^0-9\s#{escape_chars}][^\s#{escape_chars}]*)$/
    end
  end
end
