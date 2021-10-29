require "test_helper"

class DecimalTest < Minitest::Test
  def test_decimal
    value = KDL::Types::Decimal.call(::KDL::Value::String.new('10000000000000'))
    assert_equal(BigDecimal('10000000000000'), value.value)
    assert_raises { KDL::Types::Decimal.call(::KDL::Value::String.new('not a decimal')) }
  end
end
