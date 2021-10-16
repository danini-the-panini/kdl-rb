require "test_helper"

class TypesTest < Minitest::Test
  def test_types
    doc = KDL.parse_document <<-KDL
    node (date-time)"2021-01-01T12:12:12" \\
         (date)"2021-01-01" \\
         (time)"22:23:12" \\
         (duration)"P3Y6M4DT12H30M5S" \\
         (currency)"ZAR" \\
         (country-3)"ZAF" \\
         (country-2)"ZA" \\
         (ipv4)"127.0.0.1" \\
         (ipv6)"3ffe:505:2::1"
    KDL

    refute_nil doc
    assert_kind_of ::KDL::Types::DateTime, doc.nodes.first.arguments[0]
    assert_kind_of ::KDL::Types::Date, doc.nodes.first.arguments[1]
    assert_kind_of ::KDL::Types::Time, doc.nodes.first.arguments[2]
    assert_kind_of ::KDL::Types::Duration, doc.nodes.first.arguments[3]
    assert_kind_of ::KDL::Types::Currency, doc.nodes.first.arguments[4]
    assert_kind_of ::KDL::Types::Country, doc.nodes.first.arguments[5]
    assert_kind_of ::KDL::Types::Country, doc.nodes.first.arguments[6]
    assert_kind_of ::KDL::Types::IPV4, doc.nodes.first.arguments[7]
    assert_kind_of ::KDL::Types::IPV6, doc.nodes.first.arguments[8]
  end
end
