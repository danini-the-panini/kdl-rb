# frozen_string_literal: true

require "test_helper"

class URLTest < Minitest::Test
  def test_url
    value = KDL::Types::URL.call(::KDL::Value::String.new('https://www.example.com/foo/bar'))
    assert_equal URI('https://www.example.com/foo/bar'), value.value

    assert_raises { KDL::Types::URL.call(::KDL::Value::String.new('not a url')) }
    assert_raises { KDL::Types::URL.call(::KDL::Value::String.new('/reference/to/something')) }
  end

  def test_url_reference
    value = KDL::Types::URLReference.call(::KDL::Value::String.new('https://www.example.com/foo/bar'))
    assert_equal URI('https://www.example.com/foo/bar'), value.value
    value = KDL::Types::URLReference.call(::KDL::Value::String.new('/foo/bar'))
    assert_equal URI('/foo/bar'), value.value

    assert_raises { KDL::Types::URLReference.call(::KDL::Value::String.new('not a url reference')) }
  end
end
