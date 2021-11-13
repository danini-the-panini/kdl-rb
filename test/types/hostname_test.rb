require "test_helper"

class HostnameTest < Minitest::Test
  def test_hostname
    value = KDL::Types::Hostname.call(::KDL::Value::String.new('www.example.com'))
    assert_equal 'www.example.com', value.value
    refute_nil KDL::Types::Hostname.call(::KDL::Value::String.new('a'*63 + '.com'))
    refute_nil KDL::Types::Hostname.call(::KDL::Value::String.new([63, 63, 63, 61].map { |x| 'a' * x }.join('.')))

    assert_raises { KDL::Types::Hostname.call(::KDL::Value::String.new('not a hostname')) }
    assert_raises { KDL::Types::Hostname.call(::KDL::Value::String.new('-starts-with-a-dash.com')) }
    assert_raises { KDL::Types::Hostname.call(::KDL::Value::String.new('a'*64 + '.com')) }
    assert_raises { KDL::Types::Hostname.call(::KDL::Value::String.new((['a' * 63] * 4).join('.'))) }
  end

  def test_idn_hostname
    value = KDL::Types::IDNHostname.call(::KDL::Value::String.new('xn--bcher-kva.example'))
    assert_equal 'xn--bcher-kva.example', value.value
    assert_equal 'bücher.example', value.unicode_value

    value = KDL::Types::IDNHostname.call(::KDL::Value::String.new('bücher.example'))
    assert_equal 'xn--bcher-kva.example', value.value
    assert_equal 'bücher.example', value.unicode_value

    assert_raises { KDL::Types::IDNHostname.call(::KDL::Value::String.new('not an idn hostname')) }
  end
end
