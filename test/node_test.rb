require "test_helper"

class NodeTest < Minitest::Test
  def test_to_s
    value = ::KDL::Node.new("foo", [v(1), v("two")], { "three" => v(3) })

    assert_equal 'foo 1 "two" three=3', value.to_s
  end

  def test_nested_to_s
    value = ::KDL::Node.new("a1", [v("a"), v(1)], {}, [
      ::KDL::Node.new("b1", [v("b"), v(1)], {}, [
        ::KDL::Node.new("c1", [v("c"), v(1)])
      ]),
      ::KDL::Node.new("b2", [v("b"), v(2)], {}, [
        ::KDL::Node.new("c2", [v("c"), v(2)])
      ])
    ])

    assert_equal <<~KDL.strip, value.to_s
      a1 "a" 1 {
          b1 "b" 1 {
              c1 "c" 1
          }
          b2 "b" 2 {
              c2 "c" 2
          }
      }
    KDL
  end

  private

  def v(x)
    ::KDL::Value.from(x)
  end
end
