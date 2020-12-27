require "test_helper"

class ParserTest < Minitest::Test
  def setup
    @parser = ::KDL::Parser.new
  end

  def test_basic
    doc = @parser.parse('title "Hello, World"')
    nodes = nodes! {
      title "Hello, World"
    }
    assert_equal nodes.to_s, doc.to_s
  end

  def test_multiple_values
    doc = @parser.parse('bookmarks 12 15 188 1234')
    nodes = nodes! {
      bookmarks 12, 15, 188, 1234
    }
    assert_equal nodes.to_s, doc.to_s
  end

  def test_properties
    doc = @parser.parse <<~KDL
      author "Alex Monad" email="alex@example.com" active=true
      foo bar=true "baz" quux=false 1 2 3
    KDL
    nodes = nodes! {
      author "Alex Monad", email: "alex@example.com", active: true
      foo "baz", 1, 2, 3, bar: true, quux: false
    }
    assert_equal nodes.to_s, doc.to_s
  end

  def test_nested_child_nodes
    doc = @parser.parse <<~KDL
      contents {
        section "First section" {
          paragraph "This is the first paragraph"
          paragraph "This is the second paragraph"
        }
      }
    KDL
    nodes = nodes! {
      contents {
        section("First section") {
          paragraph "This is the first paragraph"
          paragraph "This is the second paragraph"
        }
      }
    }
    assert_equal nodes.to_s, doc.to_s
  end

  def test_semicolon
    doc = @parser.parse('node1; node2; node3;')
    nodes = nodes! {
      node1; node2; node3;
    }
    assert_equal nodes.to_s, doc.to_s
  end

  def test_raw_strings
    doc = @parser.parse <<~KDL
      node "this\nhas\tescapes"
      other r"C:\Users\zkat\"
      other-raw r#"hello"world"#
    KDL
    nodes = nodes! {
      node "this\nhas\tescapes"
      other "C:\\Users\\zkat\\"
      _ 'other-raw', "hello\"world"
    }
    assert_equal nodes.to_s, doc.to_s
  end

  def test_multiline_strings
    doc = @parser.parse <<~KDL
      string "my
      multiline
      value"
    KDL
    nodes = nodes! {
      string "my\nmultiline\nvalue"
    }
    assert_equal nodes.to_s, doc.to_s
  end

  def test_numbers
    doc = @parser.parse <<~KDL
      num 1.234e-42
      my-hex 0xdeadbeef
      my-octal 0o755
      my-binary 0b10101101
      bignum 1_000_000
    KDL
    nodes = nodes! {
      num 1.234e-42
      _ 'my-hex', 0xdeadbeef
      _ 'my-octal', 0o755
      _ 'my-binary', 0b10101101
      bignum 1_000_000
    }
    assert_equal nodes.to_s, doc.to_s
  end

  def test_comments
    doc = @parser.parse <<~KDL
      // C style

      /*
      C style multiline
      */

      tag /*foo=true*/ bar=false

      /*/*
      hello
      */*/
    KDL
    nodes = nodes! {
      tag bar: false
    }
    assert_equal nodes.to_s, doc.to_s
  end

  def test_slash_dash
    doc = @parser.parse <<~KDL
      /-mynode "foo" key=1 {
        a
        b
        c
      }

      mynode /-"commented" "not commented" /-key="value" /-{
        a
        b
      }
    KDL
    nodes = nodes! {
      mynode "not commented"
    }
    assert_equal nodes.to_s, doc.to_s
  end

  def test_multiline_nodes
    doc = @parser.parse <<~KDL
      title \
        "Some title"
    KDL
    nodes = nodes! {
      title "Some title"
    }
    assert_equal nodes.to_s, doc.to_s
  end

  def test_utf8
    doc = @parser.parse <<~KDL
      smile "😁"
      ノード お名前＝"☜(ﾟヮﾟ☜)"
    KDL
    nodes = ::KDL::Document.new([
      ::KDL::Node.new('smile', [::KDL::Value::String.new('😁')]),
      ::KDL::Node.new('ノード', [], { 'お名前' => ::KDL::Value::String.new('☜(ﾟヮﾟ☜)') })
    ])
    assert_equal nodes.to_s, doc.to_s
  end

  def test_node_names
    doc = @parser.parse <<~KDL
      "!@#$@$%Q#$%~@!40" "1.2.3" "!!!!!"=true
      foo123~!@#$%^&*.:'|/?+ "weeee"
    KDL
    nodes = nodes! {
      _ "!@#$@$%Q#$%~@!40" "1.2.3", "!!!!!": true
      _ "foo123~!@#$%^&*.:'|/?+", "weeee"
    }
    assert_equal nodes.to_s, doc.to_s
  end
end
