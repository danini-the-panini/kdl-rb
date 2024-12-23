require "test_helper"

class DocumentTest < Minitest::Test

  def test_ref
    doc = KDL::Document.new([
      KDL::Node.new("foo"),
      KDL::Node.new("bar")
    ])

    assert_equal doc.nodes[0], doc[0]
    assert_equal doc.nodes[1], doc[1]

    assert_equal doc.nodes[0], doc["foo"]
    assert_equal doc.nodes[0], doc[:foo]
    assert_equal doc.nodes[1], doc[:bar]

    assert_raises { doc[nil] }
  end

  def test_arg
    doc = KDL::Document.new([
      KDL::Node.new("foo", arguments: [KDL::Value::String.new("bar")]),
      KDL::Node.new("baz", arguments: [KDL::Value::String.new("qux")])
    ])

    assert_equal "bar", doc.arg(0)
    assert_equal "bar", doc.arg("foo")
    assert_equal "bar", doc.arg(:foo)
    assert_equal "qux", doc.arg(1)
    assert_equal "qux", doc.arg(:baz)
    assert_nil doc.arg(:norf)

    assert_raises { doc.arg(nil) }
  end

  def test_args
    doc = KDL::Document.new([
      KDL::Node.new("foo", arguments: [KDL::Value::String.new("bar"), KDL::Value::String.new("baz")]),
      KDL::Node.new("qux", arguments: [KDL::Value::String.new("norf")])
    ])

    assert_equal ["bar", "baz"], doc.args(0)
    assert_equal ["bar", "baz"], doc.args("foo")
    assert_equal ["bar", "baz"], doc.args(:foo)
    assert_equal ["norf"], doc.args(1)
    assert_equal ["norf"], doc.args(:qux)
    assert_nil doc.args(:wat)

    a = []; doc.each_arg("foo") { a << _1 }
    assert_equal ["bar", "baz"], a

    a = []; doc.each_arg(:wat) { a << _1 }
    assert_equal [], a

    assert_raises { doc.arg(nil) }
  end

  def test_dash_vals
    doc = KDL::Document.new([
      KDL::Node.new("node", children: [
        KDL::Node.new("-", arguments: [KDL::Value::String.new("foo")]),
        KDL::Node.new("-", arguments: [KDL::Value::String.new("bar")]),
        KDL::Node.new("-", arguments: [KDL::Value::String.new("baz")])
      ])
    ])

    assert_equal ["foo", "bar", "baz"], doc.dash_vals(0)
    assert_equal ["foo", "bar", "baz"], doc.dash_vals("node")
    assert_equal ["foo", "bar", "baz"], doc.dash_vals(:node)
    assert_nil doc.dash_vals(:nope)

    a = []; doc.each_dash_val("node") { a << _1 }
    assert_equal ["foo", "bar", "baz"], a

    a = []; doc.each_dash_val(:nope) { a << _1 }
    assert_equal [], a

    assert_raises { doc.dash_vals(nil) }
  end

  def test_each
    doc = KDL::Document.new([
      KDL::Node.new("foo"),
      KDL::Node.new("bar")
    ])

    a = []; doc.each { a << _1.name }
    assert_equal ["foo", "bar"], a
  end

  def test_inspect
    doc = KDL::Document.new([])

    assert_kind_of String, doc.inspect
  end

end
