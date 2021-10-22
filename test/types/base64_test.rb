require "test_helper"

class Base64Test < Minitest::Test
  def test_base64
    value = KDL::Types::Base64.call(::KDL::Value::String.new('U2VuZCByZWluZm9yY2VtZW50cw==\n'))
    assert_equal 'Send reinforcements', value.value
  end
end
