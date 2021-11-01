require "test_helper"

class HostnameTest < Minitest::Test
  def test_hostname
    value = KDL::Types::Hostname.call(::KDL::Value::String.new('www.example.com'))
    assert_equal 'www.example.com', value.value

    assert_raises { KDL::Types::Hostname.call(::KDL::Value::String.new('not a hostname')) }
  end

  def test_idn_hostname
    value = KDL::Types::IDNHostname.call(::KDL::Value::String.new('xn--bcher-kva.example'))
    assert_equal 'bücher.example', value.value
    assert_equal 'xn--bcher-kva.example', value.ascii_value

    assert_raises { KDL::Types::IDNHostname.call(::KDL::Value::String.new('not an idn hostname')) }
  end
end
