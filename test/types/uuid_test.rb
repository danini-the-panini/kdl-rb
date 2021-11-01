require "test_helper"

class UUIDTest < Minitest::Test
  def test_uuid
    value = KDL::Types::UUID.call(::KDL::Value::String.new('f81d4fae-7dec-11d0-a765-00a0c91e6bf6'))
    assert_equal 'f81d4fae-7dec-11d0-a765-00a0c91e6bf6', value.value
    value = KDL::Types::UUID.call(::KDL::Value::String.new('F81D4FAE-7DEC-11D0-A765-00A0C91E6BF6'))
    assert_equal 'f81d4fae-7dec-11d0-a765-00a0c91e6bf6', value.value

    assert_raises { KDL::Types::UUID.call(::KDL::Value::String.new('not a uuid')) }
  end
end
