require "test_helper"

class IPTest < Minitest::Test
  def test_ipv4
    value = KDL::Types::IPV4.parse('127.0.0.1')
    assert_equal ::IPAddr.new('127.0.0.1'), value.value

    assert_raises { KDL::Types::IPV4.parse('not an ipv4 address') }
    assert_raises { KDL::Types::IPV4.parse('3ffe:505:2::1') }
  end

  def test_ipv6
    value = KDL::Types::IPV6.parse('::')
    assert_equal ::IPAddr.new('::'), value.value
    value = KDL::Types::IPV6.parse('3ffe:505:2::1')
    assert_equal ::IPAddr.new('3ffe:505:2::1'), value.value

    assert_raises { KDL::Types::IPV6.parse('not an ipv6 address') }
    assert_raises { KDL::Types::IPV6.parse('127.0.0.1') }
  end
end
