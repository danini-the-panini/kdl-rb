require 'test_helper'

class TypesTest < Minitest::Test
  def test_types
    doc = KDL.parse_document <<-KDL
    node (date-time)"2021-01-01T12:12:12" \\
         (date)"2021-01-01" \\
         (time)"22:23:12" \\
         (duration)"P3Y6M4DT12H30M5S" \\
         (currency)"ZAR" \\
         (country-3)"ZAF" \\
         (country-2)"ZA" \\
         (ipv4)"127.0.0.1" \\
         (ipv6)"3ffe:505:2::1" \\
         (url)"https://kdl.dev" \\
         (uuid)"f81d4fae-7dec-11d0-a765-00a0c91e6bf6" \\
         (regex)"asdf" \\
         (base64)"U2VuZCByZWluZm9yY2VtZW50cw==\n"
    KDL

    refute_nil doc
    assert_kind_of ::KDL::Types::DateTime, doc.nodes.first.arguments[0]
    assert_kind_of ::KDL::Types::Date, doc.nodes.first.arguments[1]
    assert_kind_of ::KDL::Types::Time, doc.nodes.first.arguments[2]
    assert_kind_of ::KDL::Types::Duration, doc.nodes.first.arguments[3]
    assert_kind_of ::KDL::Types::Currency, doc.nodes.first.arguments[4]
    assert_kind_of ::KDL::Types::Country, doc.nodes.first.arguments[5]
    assert_kind_of ::KDL::Types::Country, doc.nodes.first.arguments[6]
    assert_kind_of ::KDL::Types::IPV4, doc.nodes.first.arguments[7]
    assert_kind_of ::KDL::Types::IPV6, doc.nodes.first.arguments[8]
    assert_kind_of ::KDL::Types::URL, doc.nodes.first.arguments[9]
    assert_kind_of ::KDL::Types::UUID, doc.nodes.first.arguments[10]
    assert_kind_of ::KDL::Types::Regex, doc.nodes.first.arguments[11]
  end

  def test_custom_types
    parsers = {
      'foo' => lambda { |value, type|
        Foo.new(value.value, type: type) if value.is_a?(KDL::Value)
      },
      'bar' => lambda { |node, type|
        Bar.new(node, type: type) if node.is_a?(KDL::Node)
      }
    }
    doc = KDL.parse_document <<-KDL, type_parsers: parsers
    (bar)barnode (foo)"foovalue"
    (foo)foonode (bar)"barvalue"
    KDL
    refute_nil doc
    assert_kind_of Bar, doc.nodes.first
    assert_kind_of Foo, doc.nodes.first.arguments.first
    assert_kind_of KDL::Node, doc.nodes[1]
    assert_kind_of KDL::Value, doc.nodes[1].arguments.first
  end

  class Foo < KDL::Value
  end

  class Bar < KDL::Node
    def initialize(node, type: nil)
      super(node.name, node.arguments, node.properties, node.children, type: type)
    end
  end
end
