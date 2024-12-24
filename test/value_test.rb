require "test_helper"

class ValueTest < Minitest::Test
  def test_to_s
    assert_equal "1", ::KDL::Value::Int.new(1).to_s
    assert_equal "1.5", ::KDL::Value::Float.new(1.5).to_s
    assert_equal "#inf", ::KDL::Value::Float.new(Float::INFINITY).to_s
    assert_equal "#-inf", ::KDL::Value::Float.new(-Float::INFINITY).to_s
    assert_equal "#nan", ::KDL::Value::Float.new(Float::NAN).to_s
    assert_equal "#true", ::KDL::Value::Boolean.new(true).to_s
    assert_equal "#false", ::KDL::Value::Boolean.new(false).to_s
    assert_equal "#null", ::KDL::Value::Null.to_s
    assert_equal 'foo', ::KDL::Value::String.new("foo").to_s
    assert_equal '"foo \"bar\" baz"', ::KDL::Value::String.new('foo "bar" baz').to_s
    assert_equal '(ty)foo', ::KDL::Value::String.new("foo", type: 'ty').to_s
  end

  def test_from
    assert_equal(KDL::Value::Int.new(1), KDL::Value::from(1))
    assert_equal(KDL::Value::Float.new(1.5), KDL::Value::from(1.5))
    assert_equal(
      KDL::Value::String.new("foo"),
      KDL::Value::from("foo")
    )
    assert_equal(KDL::Value::String.new("bar"), KDL::Value::from("bar"))
    assert_equal(KDL::Value::Boolean.new(true), KDL::Value::from(true))
    assert_equal(KDL::Value::Null, KDL::Value::from(nil))
    assert_raises { ::KDL::Value.from(Object.new) }
  end

  def test_equal
    assert_equal ::KDL::Value::Int.new(42), ::KDL::Value::Int.new(42)
    assert_equal ::KDL::Value::Float.new(3.14), ::KDL::Value::Float.new(3.14)
    assert_equal ::KDL::Value::Float.new(::Float::NAN), ::KDL::Value::Float.new(::Float::NAN)
    assert_equal ::KDL::Value::Boolean.new(true), ::KDL::Value::Boolean.new(true)
    assert_equal ::KDL::Value::NullImpl.new, ::KDL::Value::NullImpl.new
    assert_equal ::KDL::Value::String.new("lorem"), ::KDL::Value::String.new("lorem")

    assert_equal ::KDL::Value::Int.new(42), 42
    assert_equal ::KDL::Value::Float.new(3.14), 3.14
    assert_equal ::KDL::Value::Boolean.new(true), true
    assert_equal ::KDL::Value::NullImpl.new, nil
    assert_equal ::KDL::Value::String.new("lorem"), "lorem"

    refute_equal ::KDL::Value::Int.new(69), ::KDL::Value::Int.new(42)
    refute_equal ::KDL::Value::Float.new(6.28), ::KDL::Value::Float.new(3.14)
    refute_equal ::KDL::Value::Boolean.new(false), ::KDL::Value::Boolean.new(true)
    refute_equal ::KDL::Value::String.new("ipsum"), ::KDL::Value::String.new("lorem")

    refute_equal ::KDL::Value::Int.new(42), 69
    refute_equal ::KDL::Value::Float.new(3.14), 6.28
    refute_equal ::KDL::Value::Boolean.new(true), false
    refute_equal ::KDL::Value::NullImpl.new, 7
    refute_equal ::KDL::Value::String.new("lorem"), "ipsum"
  end

  class Something < KDL::Value::Custom
  end

  def test_as_type
    value = ::KDL::Value::String.new("foo")
    assert_equal "bar", value.as_type("bar").type
    assert_kind_of Something, value.as_type("bar", lambda { |v, type| Something.new(v) })
    nil_parse = value.as_type("bar", lambda { |v, type| nil })
    assert_equal value, nil_parse
    assert_equal "bar", nil_parse.type

    assert_raises { value.as_type("bar", lambda { |v, type| Object.new }) }
  end

  def test_inspect
    assert_equal "1", ::KDL::Value::Int.new(1).inspect
    assert_equal "1.5", ::KDL::Value::Float.new(1.5).inspect
    assert_equal "true", ::KDL::Value::Boolean.new(true).inspect
    assert_equal "false", ::KDL::Value::Boolean.new(false).inspect
    assert_equal "nil", ::KDL::Value::Null.inspect
    assert_equal '"foo"', ::KDL::Value::String.new("foo").inspect
    assert_equal '"foo \"bar\" baz"', ::KDL::Value::String.new('foo "bar" baz').inspect
    assert_equal '("ty")"foo"', ::KDL::Value::String.new("foo", type: 'ty').inspect
  end

  def test_version
    assert_equal 2, ::KDL::Value::Int.new(1).version
    assert_equal 2, ::KDL::Value::Float.new(1.5).version
    assert_equal 2, ::KDL::Value::Boolean.new(true).version
    assert_equal 2, ::KDL::Value::Boolean.new(false).version
    assert_equal 2, ::KDL::Value::Null.version
    assert_equal 2, ::KDL::Value::String.new("foo").version
  end

  def test_to_v1
    [
      ::KDL::Value::Int.new(1),
      ::KDL::Value::Float.new(1.5),
      ::KDL::Value::Boolean.new(true),
      ::KDL::Value::Boolean.new(false),
      ::KDL::Value::Null,
      ::KDL::Value::String.new("foo")
    ].each do |v|
      v1 = v.to_v1
      assert_equal 1, v1.version
      assert_equal v, v1
      assert_equal v1, v
    end
  end

  def test_to_v2
    [
      ::KDL::Value::Int.new(1),
      ::KDL::Value::Float.new(1.5),
      ::KDL::Value::Boolean.new(true),
      ::KDL::Value::Boolean.new(false),
      ::KDL::Value::Null,
      ::KDL::Value::String.new("foo")
    ].each do |v|
      assert_same v, v.to_v2
    end
  end

  def test_method_missing
    v = ::KDL::Value::String.new("foo")

    assert v.respond_to?(:upcase)
    assert_equal "FOO", v.upcase
  end
end
