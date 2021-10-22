require "test_helper"

class URLTest < Minitest::Test
  def test_url
    value = KDL::Types::URL.call(::KDL::Value::String.new('https://www.example.com/foo/bar'))
    assert_equal URI('https://www.example.com/foo/bar'), value.value

    assert_raises { KDL::Types::URL.call(::KDL::Value::String.new('not a url')) }
  end
end
