require "test_helper"

class Base64Test < Minitest::Test
  def test_base64
    value = KDL::Types::Base64.parse('U2VuZCByZWluZm9yY2VtZW50cw==\n')
    assert_equal 'Send reinforcements', value.value
  end
end
