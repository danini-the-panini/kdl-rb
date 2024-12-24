module KDL
  class Error < StandardError; end
  class VersionMismatchError < Error
    attr_reader :version, :parser_version

    def initialize(message, version, parser_version)
      super(message, 0, 0)
      @version = version
      @parser_version = parser_version
    end
  end
end
