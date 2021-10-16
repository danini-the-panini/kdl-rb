require "test_helper"

class RegexTest < Minitest::Test
  def test_regex
    value = KDL::Types::Regex.parse('asdf')
    assert_equal(/asdf/, value.value)
  end
end
