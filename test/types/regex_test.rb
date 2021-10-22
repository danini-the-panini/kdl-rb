require "test_helper"

class RegexTest < Minitest::Test
  def test_regex
    value = KDL::Types::Regex.call(::KDL::Value::String.new('asdf'))
    assert_equal(/asdf/, value.value)
  end
end
