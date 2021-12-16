require "test_helper"

class RegexTest < Minitest::Test
  def test_regex
    value = KDL::Types::Regex.call(::KDL::Value::String.new('asdf'))
    assert_equal(/asdf/, value.value)

    assert_raises { KDL::Types::Regex.call(::KDL::Value::String.new('invalid(regex]')) }
  end
end
