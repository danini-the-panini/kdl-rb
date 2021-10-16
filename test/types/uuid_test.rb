require "test_helper"

class UUIDTest < Minitest::Test
  def test_url
    value = KDL::Types::UUID.parse('f81d4fae-7dec-11d0-a765-00a0c91e6bf6')
    assert_equal 'f81d4fae-7dec-11d0-a765-00a0c91e6bf6', value.value
    value = KDL::Types::UUID.parse('F81D4FAE-7DEC-11D0-A765-00A0C91E6BF6')
    assert_equal 'f81d4fae-7dec-11d0-a765-00a0c91e6bf6', value.value

    assert_raises { KDL::Types::UUID.parse('not a uuid') }
  end
end
