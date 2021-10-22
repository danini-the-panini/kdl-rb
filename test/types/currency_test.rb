require 'test_helper'

class CurrencyTest < Minitest::Test
  def test_currency
    value = KDL::Types::Currency.call(::KDL::Value::String.new('ZAR'))
    assert_equal({ numeric_code: 710,
                   minor_unit: 2,
                   name: 'South African rand' }, value.value)

    assert_raises { KDL::Types::Currency.call(::KDL::Value::String.new('ZZZ')) }
  end
end
