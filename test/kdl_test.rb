require "test_helper"

class KDLTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::KDL::VERSION
  end

  def test_parse_document
    assert_equal KDL.parse('node 1 2 3'), KDL.parse_document('node 1 2 3')
  end
end
