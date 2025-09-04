# frozen_string_literal: true

require "test_helper"

class BuilderTest < Minitest::Test
  def test_build
    doc = KDL.build do |kdl|
      kdl.node "foo"
      kdl.node "bar", type: "baz"
      kdl.node "qux" do
        kdl.arg 123
        kdl.prop "norf", "wat"
        kdl.prop "when", "2025-01-30", type: "date"
        kdl.node "child"
      end
    end

    assert_equal <<~KDL, doc.to_s
      foo
      (baz)bar
      qux 123 norf=wat when=(date)"2025-01-30" {
          child
      }
    KDL
  end

  def test_shorthand
    doc = KDL.build do |kdl|
      kdl.node "pokemon", "snorlax", { "Pokemon type" => "normal" }, "jigglypuff", level: 10, trainer: "Sylphrena"
    end

    assert_equal <<~KDL, doc.to_s
      pokemon snorlax jigglypuff "Pokemon type"=normal level=10 trainer=Sylphrena
    KDL
  end

  def test_implicit_block
    doc = KDL.build do
      node "foo"
      node "bar", type: "baz"
      node "qux" do
        arg 123
        prop "norf", "wat"
        prop "when", "2025-01-30", type: "date"
        node "child"
      end
    end

    assert_equal <<~KDL, doc.to_s
      foo
      (baz)bar
      qux 123 norf=wat when=(date)"2025-01-30" {
          child
      }
    KDL
  end

  def test_magic_nodes
    doc = KDL.build do
      foo
      bar type: "baz"
      qux do
        arg 123
        prop "norf", "wat"
        prop "when", "2025-01-30", type: "date"
        _ "child"
      end
    end

    assert_equal <<~KDL, doc.to_s
      foo
      (baz)bar
      qux 123 norf=wat when=(date)"2025-01-30" {
          child
      }
    KDL
  end

  def test_failures
    assert_raises do
      KDL.build do |kdl|
        kdl.prop foo: "bar"
      end
    end

    assert_raises do
      KDL.build do |kdl|
        kdl.arg "asdf"
      end
    end
  end
  
end
