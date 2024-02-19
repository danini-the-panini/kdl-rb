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
      KDL::Node.new("foo", [KDL::Value::String.new("bar")]),
      KDL::Node.new("baz", [KDL::Value::String.new("qux")])
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
      KDL::Node.new("foo", [KDL::Value::String.new("bar"), KDL::Value::String.new("baz")]),
      KDL::Node.new("qux", [KDL::Value::String.new("norf")])
    ])

    assert_equal ["bar", "baz"], doc.args(0)
    assert_equal ["bar", "baz"], doc.args("foo")
    assert_equal ["bar", "baz"], doc.args(:foo)
    assert_equal ["norf"], doc.args(1)
    assert_equal ["norf"], doc.args(:qux)
    assert_nil doc.args(:wat)

    assert_raises { doc.arg(nil) }
  end

  def test_dash_vals
    doc = KDL::Document.new([
      KDL::Node.new("node", [], {}, [
        KDL::Node.new("-", [KDL::Value::String.new("foo")]),
        KDL::Node.new("-", [KDL::Value::String.new("bar")]),
        KDL::Node.new("-", [KDL::Value::String.new("baz")])
      ])
    ])

    assert_equal ["foo", "bar", "baz"], doc.dash_vals(0)
    assert_equal ["foo", "bar", "baz"], doc.dash_vals("node")
    assert_equal ["foo", "bar", "baz"], doc.dash_vals(:node)
  end

end
