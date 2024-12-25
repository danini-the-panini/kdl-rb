# frozen_string_literal: true

require "test_helper"

class KDL::V1::DocumentTest < Minitest::Test
  def test_version
    assert_equal 1, KDL::V1::Document.new([]).version
  end

  def test_to_v2
    doc = KDL.parse <<~KDL, version: 1
      foo "lorem" 1 true null {
        bar "
          baz
            qux
        "
      }
    KDL
    assert_equal 1, doc.version

    doc = doc.to_v2
    assert_equal 2, doc.version

    assert_equal <<~KDL, doc.to_s
      foo lorem 1 #true #null {
          bar "\\n    baz\\n      qux\\n  "
      }
    KDL
  end

  def test_to_v1
    doc = KDL::V1::Document.new([])
    assert_same doc, doc.to_v1
  end
end
