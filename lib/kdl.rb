require "kdl/version"
require "kdl/tokenizer"
require "kdl/document"
require "kdl/value"
require "kdl/node"
require "kdl/kdl.tab"

module KDL
  def self.parse_document(input)
    Parser.new.parse(input)
  end
end
