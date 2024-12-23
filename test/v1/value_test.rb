require "test_helper"

class KDL::V1::ValueTest < Minitest::Test
  def test_to_s
    assert_equal "1", ::KDL::V1::Value::Int.new(1).to_s
    assert_equal "1.5", ::KDL::V1::Value::Float.new(1.5).to_s
    assert_equal "null", ::KDL::V1::Value::Float.new(Float::INFINITY).to_s
    assert_equal "null", ::KDL::V1::Value::Float.new(-Float::INFINITY).to_s
    assert_equal "null", ::KDL::V1::Value::Float.new(Float::NAN).to_s
    assert_equal "true", ::KDL::V1::Value::Boolean.new(true).to_s
    assert_equal "false", ::KDL::V1::Value::Boolean.new(false).to_s
    assert_equal "null", ::KDL::V1::Value::Null.to_s
    assert_equal '"foo"', ::KDL::V1::Value::String.new("foo").to_s
    assert_equal '"foo \"bar\" baz"', ::KDL::V1::Value::String.new('foo "bar" baz').to_s
    assert_equal '(ty)"foo"', ::KDL::V1::Value::String.new("foo", type: 'ty').to_s
  end

  def test_from
    assert_equal(::KDL::V1::Value::Int.new(1), ::KDL::V1::Value::from(1))
    assert_equal(::KDL::V1::Value::Float.new(1.5), ::KDL::V1::Value::from(1.5))
    assert_equal(
      ::KDL::V1::Value::String.new("foo"),
      ::KDL::V1::Value::from("foo")
    )
    assert_equal(::KDL::V1::Value::String.new("bar"), ::KDL::V1::Value::from("bar"))
    assert_equal(::KDL::V1::Value::Boolean.new(true), ::KDL::V1::Value::from(true))

    assert_equal(::KDL::V1::Value::Null, ::KDL::V1::Value::from(nil))
  end
end
