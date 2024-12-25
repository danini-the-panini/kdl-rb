# frozen_string_literal: true

require "test_helper"

class NodeTest < Minitest::Test
  def test_ref
    node = KDL::Node.new("node", arguments: [v(1), v("two")], properties: { "three" => v(3), "four" => v(4) })

    assert_equal 1, node[0]
    assert_equal "two", node[1]
    assert_nil node[2]

    assert_equal 3, node["three"]
    assert_equal 3, node[:three]
    assert_equal 4, node[:four]

    assert_raises { node[nil] }
  end

  def test_child
    node = KDL::Node.new("node", children: [
      KDL::Node.new("foo"),
      KDL::Node.new("bar")
    ])

    assert_equal node.children[0], node.child(0)
    assert_equal node.children[1], node.child(1)

    assert_equal node.children[0], node.child("foo")
    assert_equal node.children[0], node.child(:foo)
    assert_equal node.children[1], node.child(:bar)

    a = []; node.each { a << _1.name }
    assert_equal ["foo", "bar"], a

    assert_raises { node.child(nil) }
  end

  def test_arg
    node = KDL::Node.new("node", children: [
      KDL::Node.new("foo", arguments: [KDL::Value::String.new("bar")]),
      KDL::Node.new("baz", arguments: [KDL::Value::String.new("qux")])
    ])

    assert_equal "bar", node.arg(0)
    assert_equal "bar", node.arg("foo")
    assert_equal "bar", node.arg(:foo)
    assert_equal "qux", node.arg(1)
    assert_equal "qux", node.arg(:baz)
    assert_nil node.arg(:norf)

    assert_raises { node.arg(nil) }
  end

  def test_args
    node = KDL::Node.new("node", children: [
      KDL::Node.new("foo", arguments: [KDL::Value::String.new("bar"), KDL::Value::String.new("baz")]),
      KDL::Node.new("qux", arguments: [KDL::Value::String.new("norf")])
    ])

    assert_equal ["bar", "baz"], node.args(0)
    assert_equal ["bar", "baz"], node.args("foo")
    assert_equal ["bar", "baz"], node.args(:foo)
    assert_equal ["norf"], node.args(1)
    assert_equal ["norf"], node.args(:qux)
    assert_nil node.args(:wat)

    a = []; node.each_arg(:foo) { a << _1 }
    assert_equal ["bar", "baz"], a

    a = []; node.each_arg(:wat) { a << _1 }
    assert_equal [], a

    assert_raises { node.args(nil) }
  end

  def test_dash_vals
    node = KDL::Node.new("node", children: [
      KDL::Node.new("node", children: [
        KDL::Node.new("-", arguments: [KDL::Value::String.new("foo")]),
        KDL::Node.new("-", arguments: [KDL::Value::String.new("bar")]),
        KDL::Node.new("-", arguments: [KDL::Value::String.new("baz")])
      ])
    ])

    assert_equal ["foo", "bar", "baz"], node.dash_vals(0)
    assert_equal ["foo", "bar", "baz"], node.dash_vals("node")
    assert_equal ["foo", "bar", "baz"], node.dash_vals(:node)
    assert_nil node.dash_vals(:nope)

    a = []; node.each_dash_val(:node) { a << _1 }
    assert_equal ["foo", "bar", "baz"], a

    a = []; node.each_dash_val(:nope) { a << _1 }
    assert_equal [], a

    assert_raises { node.dash_vals(nil) }
  end

  def test_to_s
    node = ::KDL::Node.new("foo", arguments: [v(1), v("two")], properties: { "three" => v(3) })

    assert_equal 'foo 1 two three=3', node.to_s
  end

  def test_nested_to_s
    node = ::KDL::Node.new("a1", arguments: [v("a"), v(1)], properties: { a: v(1) }, children: [
      ::KDL::Node.new("b1", arguments: [v("b"), v(1, "foo")], children: [
        ::KDL::Node.new("c1", arguments: [v("c"), v(1)])
      ]),
      ::KDL::Node.new("b2", arguments: [v("b")], properties: { c: v(2, "bar") }, children: [
        ::KDL::Node.new("c2", arguments: [v("c"), v(2)])
      ]),
      ::KDL::Node.new("b3", type: "baz"),
    ])

    assert_equal <<~KDL.strip, node.to_s
      a1 a 1 a=1 {
          b1 b (foo)1 {
              c1 c 1
          }
          b2 b c=(bar)2 {
              c2 c 2
          }
          (baz)b3
      }
    KDL

    assert_equal <<~KDL.strip, node.inspect
      "a1" "a" 1 "a"=1 {
          "b1" "b" ("foo")1 {
              "c1" "c" 1
          }
          "b2" "b" "c"=("bar")2 {
              "c2" "c" 2
          }
          ("baz")"b3"
      }
    KDL
  end

  def test_compare
    a = KDL::Node.new("a")
    b = KDL::Node.new("b")

    assert_equal -1, a <=> b
    assert_equal  1, b <=> a
    assert_equal  0, a <=> a
  end

  class Something < KDL::Node::Custom
  end

  def test_as_type
    node = KDL::Node.new("foo")
    assert_equal "bar", node.as_type("bar").type
    assert_kind_of Something, node.as_type("bar", lambda { |n, type| Something.new(n) })
    nil_parse = node.as_type("bar", lambda { |n, type| nil })
    assert_equal node, nil_parse
    assert_equal "bar", nil_parse.type

    assert_raises { node.as_type("bar", lambda { |n, type| Object.new }) }
  end

  def test_version
    node = KDL::Node.new("foo")
    assert_equal 2, node.version
  end

  def test_to_v1
    node = KDL::Node.new("foo",
      arguments: [v(true)],
      properties: { bar: v("baz") },
      children: [KDL::Node.new("qux")]
    )

    node = node.to_v1
    assert_equal 1, node.version
    assert_equal 1, node.arguments[0].version
    assert_equal 1, node.properties['bar'].version
    assert_equal 1, node.child(0).version
  end

  def test_to_v2
    node = KDL::Node.new("foo")
    assert_same node, node.to_v2
  end

  private

  def v(x, t=nil)
    val = ::KDL::Value.from(x)
    return val.as_type(t) if t
    val
  end
end
