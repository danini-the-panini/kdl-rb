require "kdl/version"
require "kdl/tokenizer"
require "kdl/document"
require "kdl/value"
require "kdl/node"
require "kdl/string_dumper"
require "kdl/types"
require "kdl/parser_common"
require "kdl/kdl.tab"
require "kdl/v1"

module KDL
  def self.parse_document(input, options = {})
    warn "[DEPRECATION] `KDL.parse_document' is deprecated. Please use `KDL.parse' instead."
    parse(input, **options)
  end

  def self.parse(input, mode: :auto, output: nil, **options)
    case mode
    when :auto
      auto_parse(input, output:, **options)
    when :v2
      Parser.new(output_module: output_module(output || :v2), **options).parse(input)
    when :v1
      V1::Parser.new.parse(input, output_module: output_module(output || :v1), **options)
    end
  end

  def self.load_file(filespec, **options)
    parse(File.read(filespec, encoding: Encoding::UTF_8), **options)
  end

  def self.auto_parse(input, output: nil, **options)
    # TODO: read directive
    parse(input, mode: :v2, output: output || :v2, **options)
  rescue => e
    parse(input, mode: :v1, output: output || :v1, **options) rescue raise e
  end

  def self.output_module(mode)
    case mode
    when :v1 then KDL::V1
    else KDL
    end
  end
end
