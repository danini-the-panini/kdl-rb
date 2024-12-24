# frozen_string_literal: true

module KDL
  class Error < StandardError
    attr_reader :filename, :line, :column

    def initialize(message, filename = nil, line = nil, column = nil)
      message += " (#{line}:#{column})" if line
      message = "#{[filename, line, column].compact.join(':')}: #{message}" if filename
      super(message)
      @filename = filename
      @line = line
      @column = column
    end
  end

  class VersionMismatchError < Error
    attr_reader :version, :parser_version

    def initialize(message, version = nil, parser_version = nil, filename = nil)
      super(message, filename, 1, 1)
      @version = version
      @parser_version = parser_version
    end
  end

  class UnsupportedVersionError < Error
    attr_reader :version

    def initialize(message, version = nil, filename = nil)
      super(message, filename, 1, 1)
      @version = version
    end
  end

  class ParseError < Error; end
end
