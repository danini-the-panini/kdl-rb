require "test_helper"

class Base64Test < Minitest::Test
  def test_base64
    value = KDL::Types::Base64.call(::KDL::Value::String.new('U2VuZCByZWluZm9yY2VtZW50cw=='))
    assert_equal 'Send reinforcements', value.value

    assert_raises { KDL::Types::Base64.call(::KDL::Value::String.new('not base64')) }
  end
end
