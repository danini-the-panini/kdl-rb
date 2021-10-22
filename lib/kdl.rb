require "kdl/version"
require "kdl/tokenizer"
require "kdl/document"
require "kdl/value"
require "kdl/node"
require "kdl/string_dumper"
require "kdl/types"
require "kdl/kdl.tab"

module KDL
  def self.parse_document(input, options = {})
    Parser.new.parse(input, options)
  end
end
