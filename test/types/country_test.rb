require 'test_helper'

class CountryTest < Minitest::Test
  def test_country3
    value = KDL::Types::Country3.call(::KDL::Value::String.new('ZAF'))
    assert_equal({ alpha3: 'ZAF',
                   alpha2: 'ZA',
                   numeric_code: 710,
                   name: 'South Africa' }, value.value)

    assert_raises { KDL::Types::Country3.call(::KDL::Value::String.new('ZZZ')) }
  end
  def test_country2
    value = KDL::Types::Country2.call(::KDL::Value::String.new('ZA'))
    assert_equal({ alpha3: 'ZAF',
                   alpha2: 'ZA',
                   numeric_code: 710,
                   name: 'South Africa' }, value.value)

    assert_raises { KDL::Types::Country2.call(::KDL::Value::String.new('ZZ')) }
  end
end
