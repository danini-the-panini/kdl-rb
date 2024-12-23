require "kdl/version"
require "kdl/tokenizer"
require "kdl/document"
require "kdl/value"
require "kdl/node"
require "kdl/string_dumper"
require "kdl/types"
require "kdl/kdl.tab"

module KDL
  def self.parse(input, **options)
    Parser.new.parse(input, **options)
  end

  def self.load_file(filespec, **options)
    Parser.new.parse(File.read(filespec, encoding: Encoding::UTF_8), **options)
  end
end
