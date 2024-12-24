module KDL
  class Error < StandardError; end

  class VersionMismatchError < Error
    attr_reader :version, :parser_version

    def initialize(message, version = nil, parser_version = nil)
      super(message)
      @version = version
      @parser_version = parser_version
    end
  end

  class UnsupportedVersionError < Error
    attr_reader :version

    def initialize(message, version = nil)
      super(message)
      @version = version
    end
  end
end
