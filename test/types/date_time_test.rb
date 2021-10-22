require "test_helper"

class DateTimeTest < Minitest::Test
  def test_date_time
    value = KDL::Types::DateTime.call(::KDL::Value::String.new('2011-10-05T22:26:12-04:00'))
    assert_equal ::Time.iso8601('2011-10-05T22:26:12-04:00'), value.value

    assert_raises { KDL::Types::DateTime.call(::KDL::Value::String.new('not a date-time')) }
  end

  def test_time
    today = ::Date.today.iso8601
    value = KDL::Types::Time.call(::KDL::Value::String.new('22:26:12'))
    assert_equal ::Time.parse("#{today}T22:26:12"), value.value
    value = KDL::Types::Time.call(::KDL::Value::String.new('T22:26:12Z'))
    assert_equal ::Time.parse("#{today}T22:26:12Z"), value.value
    value = KDL::Types::Time.call(::KDL::Value::String.new('22:26:12.000Z'))
    assert_equal ::Time.parse("#{today}T22:26:12Z"), value.value
    value = KDL::Types::Time.call(::KDL::Value::String.new('22:26:12-04:00'))
    assert_equal ::Time.parse("#{today}T22:26:12-04:00"), value.value

    assert_raises { KDL::Types::DateTime.call(::KDL::Value::String.new('not a time')) }
  end

  def test_date
    value = KDL::Types::Date.call(::KDL::Value::String.new('2011-10-05'))
    assert_equal ::Date.iso8601('2011-10-05'), value.value

    assert_raises { KDL::Types::DateTime.call(::KDL::Value::String.new('not a date')) }
  end
end
