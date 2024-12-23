require "kdl/version"
require "kdl/tokenizer"
require "kdl/document"
require "kdl/value"
require "kdl/node"
require "kdl/string_dumper"
require "kdl/types"
require "kdl/kdl.tab"
require "kdl/v1"

module KDL
  def self.parse_document(input, options = {})
    warn "[DEPRECATION] `KDL.parse_document' is deprecated. Please use `KDL.parse' instead."
    parse(input, **options)
  end

  def self.parse(input, mode: :auto, **options)
    case mode
    when :auto
      auto_parse(input, **options)
    when :v2
      Parser.new.parse(input, **options)
    when :v1
      V1::Parser.new.parse(input, **options)
    end
  end

  def self.load_file(filespec, **options)
    parse(File.read(filespec, encoding: Encoding::UTF_8), **options)
  end

  def self.auto_parse(input, **options)
    # TODO: read directive
    parse(input, mode: :v2)
  rescue => e
    parse(input, mode: :v1) rescue raise e
  end
end
