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
         (country-subdivision)"ZA-GP" \\
         (ipv4)"127.0.0.1" \\
         (ipv6)"3ffe:505:2::1" \\
         (url)"https://kdl.dev" \\
         (url-reference)"/foo/bar" \\
         (uuid)"f81d4fae-7dec-11d0-a765-00a0c91e6bf6" \\
         (regex)"asdf" \\
         (base64)"U2VuZCByZWluZm9yY2VtZW50cw==\n" \\
         (decimal)"10000000000000" \\
         (hostname)"www.example.com" \\
         (idn-hostname)"xn--bcher-kva.example" \\
         (email)"simple@example.com" \\
         (idn-email)"🌈@xn--9ckb.com" \\
         (irl)"https://kdl.dev/🦄" \\
         (irl-reference)"/🌈/🦄" \\
         (url-template)"https://kdl.dev/{foo}"
    KDL

    refute_nil doc
    i = -1
    assert_kind_of ::KDL::Types::DateTime, doc.nodes.first.arguments[i += 1]
    assert_kind_of ::KDL::Types::Date, doc.nodes.first.arguments[i += 1]
    assert_kind_of ::KDL::Types::Time, doc.nodes.first.arguments[i += 1]
    assert_kind_of ::KDL::Types::Duration, doc.nodes.first.arguments[i += 1]
    assert_kind_of ::KDL::Types::Currency, doc.nodes.first.arguments[i += 1]
    assert_kind_of ::KDL::Types::Country3, doc.nodes.first.arguments[i += 1]
    assert_kind_of ::KDL::Types::Country2, doc.nodes.first.arguments[i += 1]
    assert_kind_of ::KDL::Types::CountrySubdivision, doc.nodes.first.arguments[i += 1]
    assert_kind_of ::KDL::Types::IPV4, doc.nodes.first.arguments[i += 1]
    assert_kind_of ::KDL::Types::IPV6, doc.nodes.first.arguments[i += 1]
    assert_kind_of ::KDL::Types::URL, doc.nodes.first.arguments[i += 1]
    assert_kind_of ::KDL::Types::URLReference, doc.nodes.first.arguments[i += 1]
    assert_kind_of ::KDL::Types::UUID, doc.nodes.first.arguments[i += 1]
    assert_kind_of ::KDL::Types::Regex, doc.nodes.first.arguments[i += 1]
    assert_kind_of ::KDL::Types::Base64, doc.nodes.first.arguments[i += 1]
    assert_kind_of ::KDL::Types::Decimal, doc.nodes.first.arguments[i += 1]
    assert_kind_of ::KDL::Types::Hostname, doc.nodes.first.arguments[i += 1]
    assert_kind_of ::KDL::Types::IDNHostname, doc.nodes.first.arguments[i += 1]
    assert_kind_of ::KDL::Types::Email, doc.nodes.first.arguments[i += 1]
    assert_kind_of ::KDL::Types::IDNEmail, doc.nodes.first.arguments[i += 1]
    assert_kind_of ::KDL::Types::IRL, doc.nodes.first.arguments[i += 1]
    assert_kind_of ::KDL::Types::IRLReference, doc.nodes.first.arguments[i += 1]
    assert_kind_of ::KDL::Types::URLTemplate, doc.nodes.first.arguments[i += 1]
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

  def test_parse_false
    doc = KDL.parse_document <<-KDL, parse_types: false
    node (date-time)"2021-01-01T12:12:12"
    KDL

    refute_nil doc
    assert_kind_of ::KDL::Value::String, doc.nodes.first.arguments.first
  end

  class Foo < KDL::Value
  end

  class Bar < KDL::Node
    def initialize(node, type: nil)
      super(node.name, node.arguments, node.properties, node.children, type: type)
    end
  end
end
