# frozen_string_literal: true

require "kdl/version"
require "kdl/error"
require "kdl/tokenizer"
require "kdl/document"
require "kdl/value"
require "kdl/node"
require "kdl/string_dumper"
require "kdl/types"
require "kdl/parser_common"
require "kdl/kdl.tab"
require "kdl/builder"
require "kdl/v1"

module KDL
  class << self
    attr_accessor :default_version
    attr_accessor :default_output_version
  end

  def self.parse_document(input, options = {})
    warn "[DEPRECATION] `KDL.parse_document' is deprecated. Please use `KDL.parse' instead."
    parse(input, **options)
  end

  def self.parse(input, version: default_version, output_version: default_output_version, filename: nil, **options)
    case version
    when 2
      Parser.new(output_module: output_module(output_version || 2), **options).parse(input, filename:)
    when 1
      V1::Parser.new.parse(input, output_module: output_module(output_version || 1), filename:, **options)
    when nil
      auto_parse(input, output_version:, **options)
    else
      raise UnsupportedVersionError.new("unsupported version '#{version}'", version)
    end
  end

  def self.load_file(filespec, **options)
    File.open(filespec, 'r:BOM|UTF-8') do |file|
      parse(file.read, **options, filename: file.to_path)
    end
  end

  def self.auto_parse(input, output_version: default_output_version, **options)
    parse(input, version: 2, output_version: output_version || 2, **options)
  rescue VersionMismatchError => e
    parse(input, version: e.version, output_version: output_version || e.version, **options)
  rescue ParseError => e
    parse(input, version: 1, output_version: output_version || 1, **options) rescue raise e
  end

  def self.output_module(version)
    case version
    when 1 then KDL::V1
    when 2 then KDL
    else
      warn "[WARNING] Unknown output_version '#{version}', defaulting to v2"
      KDL
    end
  end

  def self.build(&block)
    builder = Builder.new
    if block.arity >= 1
      builder.document do
        yield builder
      end
    else
      builder.instance_exec(&block)
      builder.document
    end
  end
end
