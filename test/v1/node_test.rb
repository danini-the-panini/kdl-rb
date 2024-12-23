require "test_helper"

class KDL::V1::NodeTest < Minitest::Test
  def test_version
    node = KDL::V1::Node.new("foo")
    assert_equal 1, node.version
  end

  def test_to_v2
    node = KDL::V1::Node.new("foo",
      arguments: [v(true)],
      properties: { bar: v("baz") },
      children: [KDL::V1::Node.new("qux")]
    )

    node = node.to_v2
    assert_equal 2, node.version
    assert_equal 2, node[0].version
    assert_equal 2, node[:bar].version
    assert_equal 2, node.child(0).version
  end

  def test_to_v1
    node = KDL::V1::Node.new("foo")
    assert_same node, node.to_v1
  end

    private

    def v(x, t=nil)
      val = ::KDL::V1::Value.from(x)
      return val.as_type(t) if t
      val
    end
end
