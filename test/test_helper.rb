# frozen_string_literal: true

require "simplecov"
require "coveralls"
SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "kdl"

require "minitest/autorun"

class Minitest::Test

  private

  # Helper for constructing nodes
  # Basically a Ruby DSL that looks a bit like KDL
  def nodes!(&block)
    ::KDL::Document.new(Nodes.nodes!(&block))
  end

  class Nodes < BasicObject
    attr_reader :children

    def initialize
      @children = []
    end

    def method_missing(name, *args, **kwargs, &block)
      node = ::KDL::Node.new(name.to_s,
                             arguments: args.map { |a| ::KDL::Value.from(a) },
                             properties: kwargs.map { |k, v| [k.to_s, ::KDL::Value.from(v) ]}.to_h)
      node.children = block_given? ? Nodes.nodes!(&block) : []
      @children << node
    end
    alias _ method_missing

    def self.nodes!(&block)
      n = new
      n.instance_exec(&block)
      n.children
    end

    define_method(:instance_exec, ::Object.instance_method(:instance_exec))
    define_method(:block_given?, ::Object.instance_method(:block_given?))
  end
end
