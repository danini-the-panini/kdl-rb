# frozen_string_literal: true

require "test_helper"

class KDLTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::KDL::VERSION
  end

  def test_parse_document
    assert_equal KDL.parse('node 1 2 3'), KDL.parse_document('node 1 2 3')
  end

  def test_unsupported_version
    assert_raises(KDL::UnsupportedVersionError) { KDL.parse('node 1 2 3', version: 3) }
    assert_raises(KDL::UnsupportedVersionError) do
      KDL.parse <<~KDL
        /- kdl-version 3
        node 1 2 3
      KDL
    end
  end
end
