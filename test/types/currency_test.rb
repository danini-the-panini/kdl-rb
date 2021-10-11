require 'test_helper'

class CurrencyTest < Minitest::Test
  def test_currency
    value = KDL::Types::Currency.parse('ZAR')
    assert_equal({ numeric_code: 710,
                   minor_unit: 2,
                   name: 'South African rand' }, value.value)

    assert_raises { KDL::Types::Currency.parse('ZZZ') }
  end
end
