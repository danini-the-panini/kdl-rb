# frozen_string_literal: true

require "test_helper"

class IPTest < Minitest::Test
  def test_ipv4
    value = KDL::Types::IPV4.call(::KDL::Value::String.new('127.0.0.1'))
    assert_equal ::IPAddr.new('127.0.0.1'), value.value

    assert_raises { KDL::Types::IPV4.call(::KDL::Value::String.new('not an ipv4 address')) }
    assert_raises { KDL::Types::IPV4.call(::KDL::Value::String.new('3ffe:505:2::1')) }
  end

  def test_ipv6
    value = KDL::Types::IPV6.call(::KDL::Value::String.new('::'))
    assert_equal ::IPAddr.new('::'), value.value
    value = KDL::Types::IPV6.call(::KDL::Value::String.new('3ffe:505:2::1'))
    assert_equal ::IPAddr.new('3ffe:505:2::1'), value.value

    assert_raises { KDL::Types::IPV6.call(::KDL::Value::String.new('not an ipv6 address')) }
    assert_raises { KDL::Types::IPV6.call(::KDL::Value::String.new('127.0.0.1')) }
  end
end
