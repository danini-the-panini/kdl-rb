require "test_helper"

class TypesTest < Minitest::Test
  def test_types
    doc = KDL.parse_document <<-KDL
    node (date-time)"2021-01-01T12:12:12" \\
         (date)"2021-01-01" \\
         (time)"22:23:12"
    KDL

    refute_nil doc
    assert_kind_of ::KDL::Types::DateTime, doc.nodes.first.arguments[0]
    assert_kind_of ::KDL::Types::Date, doc.nodes.first.arguments[1]
    assert_kind_of ::KDL::Types::Time, doc.nodes.first.arguments[2]
  end
end
