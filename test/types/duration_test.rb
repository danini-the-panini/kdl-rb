require "test_helper"

class DurationTest < Minitest::Test
  def test_duration
    value = KDL::Types::Duration.parse('P3Y6M4DT12H30M5S')
    assert_equal({ years: 3, months: 6, days: 4, hours: 12, minutes: 30, seconds: 5 }, value.value)
    value = KDL::Types::Duration.parse('P23DT23H')
    assert_equal({ days: 23, hours: 23 }, value.value)
    value = KDL::Types::Duration.parse('P4Y')
    assert_equal({ years: 4 }, value.value)
    value = KDL::Types::Duration.parse('PT0S')
    assert_equal({ seconds: 0 }, value.value)
    value = KDL::Types::Duration.parse('P0D')
    assert_equal({ days: 0 }, value.value)
    value = KDL::Types::Duration.parse('P0.5Y')
    assert_equal({ years: 0.5 }, value.value)
    value = KDL::Types::Duration.parse('P0,5Y')
    assert_equal({ years: 0.5 }, value.value)
    value = KDL::Types::Duration.parse('P1M')
    assert_equal({ months: 1 }, value.value)
    value = KDL::Types::Duration.parse('PT1M')
    assert_equal({ minutes: 1 }, value.value)
    value = KDL::Types::Duration.parse('P7W')
    assert_equal({ weeks: 7 }, value.value)

    assert_raises { KDL::Types::Duration.parse('not a duration') }
    assert_raises { KDL::Types::Duration.parse('P') }
  end
end
