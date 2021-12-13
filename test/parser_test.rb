require "test_helper"

class ParserTest < Minitest::Test
  def setup
    @parser = ::KDL::Parser.new
  end

  def test_parse_empty_string
    assert_equal ::KDL::Document.new([]), @parser.parse('')
    assert_equal ::KDL::Document.new([]), @parser.parse(' ')
    assert_equal ::KDL::Document.new([]), @parser.parse("\n")
  end

  def test_nodes
    assert_equal ::KDL::Document.new([::KDL::Node.new('node')]),
                 @parser.parse('node')
    assert_equal ::KDL::Document.new([::KDL::Node.new('node')]),
                 @parser.parse("node\n")
    assert_equal ::KDL::Document.new([::KDL::Node.new('node')]),
                 @parser.parse("\nnode\n")
    assert_equal ::KDL::Document.new([::KDL::Node.new('node1'),
                                      ::KDL::Node.new('node2')]),
                 @parser.parse("node1\nnode2")
  end

  def test_node
    assert_equal ::KDL::Document.new([::KDL::Node.new('node')]),
                 @parser.parse('node;')
    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [::KDL::Value::Int.new(1)])]),
                 @parser.parse('node 1')
    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [::KDL::Value::Int.new(1),
                                                               ::KDL::Value::Int.new(2),
                                                               ::KDL::Value::String.new("3"),
                                                               ::KDL::Value::Boolean.new(true),
                                                               ::KDL::Value::Boolean.new(false),
                                                               ::KDL::Value::Null])]),
                 @parser.parse('node 1 2 "3" true false null')

    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [], {}, [::KDL::Node.new('node2')])]),
                 @parser.parse("node {\n  node2\n}")
    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [], {}, [::KDL::Node.new('node2')])]),
                 @parser.parse("node { node2; }")
  end

  def test_node_slashdash_comment
    assert_equal ::KDL::Document.new([]), @parser.parse('/-node')
    assert_equal ::KDL::Document.new([]), @parser.parse('/- node')
    assert_equal ::KDL::Document.new([]), @parser.parse("/- node\n")
    assert_equal ::KDL::Document.new([]), @parser.parse('/-node 1 2 3')
    assert_equal ::KDL::Document.new([]), @parser.parse('/-node key=false')
    assert_equal ::KDL::Document.new([]), @parser.parse("/-node{\nnode\n}")
    assert_equal ::KDL::Document.new([]), @parser.parse("/-node 1 2 3 key=\"value\" \\\n{\nnode\n}")
  end

  def test_arg_slashdash_comment
    assert_equal ::KDL::Document.new([::KDL::Node.new('node')]),
                 @parser.parse('node /-1')
    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [::KDL::Value::Int.new(2)])]),
                 @parser.parse('node /-1 2')
    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [::KDL::Value::Int.new(1),
                                                               ::KDL::Value::Int.new(3)])]),
                 @parser.parse('node 1 /- 2 3')
    assert_equal ::KDL::Document.new([::KDL::Node.new('node')]),
                 @parser.parse('node /--1')
    assert_equal ::KDL::Document.new([::KDL::Node.new('node')]),
                 @parser.parse('node /- -1')
    assert_equal ::KDL::Document.new([::KDL::Node.new('node')]),
                 @parser.parse("node \\\n/- -1")
  end

  def test_prop_slashdash_comment
    assert_equal ::KDL::Document.new([::KDL::Node.new('node')]),
                 @parser.parse('node /-key=1')
    assert_equal ::KDL::Document.new([::KDL::Node.new('node')]),
                 @parser.parse('node /- key=1')
    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [], { 'key' => ::KDL::Value::Int.new(1) })]),
                 @parser.parse('node key=1 /-key2=2')
  end

  def test_children_slashdash_comment
    assert_equal ::KDL::Document.new([::KDL::Node.new('node')]),
                 @parser.parse('node /-{}')
    assert_equal ::KDL::Document.new([::KDL::Node.new('node')]),
                 @parser.parse('node /- {}')
    assert_equal ::KDL::Document.new([::KDL::Node.new('node')]),
                 @parser.parse("node /-{\nnode2\n}")
  end

  def test_empty_children
    assert_equal ::KDL::Document.new([::KDL::Node.new('node')]),
                 @parser.parse('node {}')
    assert_equal ::KDL::Document.new([::KDL::Node.new('node')]),
                 @parser.parse("node {\n  /-node2\n}")
    assert_equal ::KDL::Document.new([::KDL::Node.new('node')]),
                 @parser.parse("node /-{\n  node2\n}")
  end

  def test_string
    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [::KDL::Value::String.new("")])]),
                 @parser.parse('node ""')
    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [::KDL::Value::String.new("hello")])]),
                 @parser.parse('node "hello"')
    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [::KDL::Value::String.new("hello\nworld")])]),
                 @parser.parse('node "hello\\nworld"')
    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [::KDL::Value::String.new("\u{10FFF}")])]),
                 @parser.parse('node "\\u{10FFF}"')
    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [::KDL::Value::String.new("\"\\/\u{08}\u{0C}\n\r\t")])]),
                 @parser.parse('node "\"\\\\\/\b\f\n\r\t"')
    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [::KDL::Value::String.new("\u{10}")])]),
                 @parser.parse('node "\u{10}"')
    assert_raises { @parser.parse('node "\i"') }
    assert_raises { @parser.parse('node "\u{c0ffee}"') }
  end

  def test_float
    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [::KDL::Value::Float.new(1.0)])]),
                 @parser.parse('node 1.0')
    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [::KDL::Value::Float.new(0.0)])]),
                 @parser.parse('node 0.0')
    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [::KDL::Value::Float.new(-1.0)])]),
                 @parser.parse('node -1.0')
    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [::KDL::Value::Float.new(1.0)])]),
                 @parser.parse('node +1.0')
    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [::KDL::Value::Float.new(1.0e10)])]),
                 @parser.parse('node 1.0e10')
    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [::KDL::Value::Float.new(1.0e-10)])]),
                 @parser.parse('node 1.0e-10')
    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [::KDL::Value::Float.new(123456789.0)])]),
                 @parser.parse('node 123_456_789.0')
    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [::KDL::Value::Float.new(123456789.0)])]),
                 @parser.parse('node 123_456_789.0')
    assert_raises { @parser.parse('node ?1.0') }
    assert_raises { @parser.parse('node _1.0') }
    assert_raises { @parser.parse('node 1._0') }
    assert_raises { @parser.parse('node 1.') }
    assert_raises { @parser.parse('node .0') }
  end

  def test_integer
    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [::KDL::Value::Int.new(0)])]),
                 @parser.parse('node 0')
    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [::KDL::Value::Int.new(123456789)])]),
                 @parser.parse('node 0123456789')
    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [::KDL::Value::Int.new(123456789)])]),
                 @parser.parse('node 0123_456_789')
    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [::KDL::Value::Int.new(123456789)])]),
                 @parser.parse('node 0123_456_789_')
    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [::KDL::Value::Int.new(123456789)])]),
                 @parser.parse('node +0123456789')
    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [::KDL::Value::Int.new(-123456789)])]),
                 @parser.parse('node -0123456789')
    assert_raises { @parser.parse('node ?0123456789') }
    assert_raises { @parser.parse('node _0123456789') }
    assert_raises { @parser.parse('node a') }
    assert_raises { @parser.parse('node --') }
  end

  def test_hexadecimal
    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [::KDL::Value::Int.new(0x0123456789abcdef)])]),
                 @parser.parse('node 0x0123456789abcdef')
    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [::KDL::Value::Int.new(0x0123456789abcdef)])]),
                 @parser.parse('node 0x01234567_89abcdef')
    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [::KDL::Value::Int.new(0x0123456789abcdef)])]),
                 @parser.parse('node 0x01234567_89abcdef_')
    assert_raises { @parser.parse('node 0x_123') }
    assert_raises { @parser.parse('node 0xg') }
    assert_raises { @parser.parse('node 0xx') }
  end

  def test_octal
    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [::KDL::Value::Int.new(0o01234567)])]),
                 @parser.parse('node 0o01234567')
    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [::KDL::Value::Int.new(0o01234567)])]),
                 @parser.parse('node 0o0123_4567')
    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [::KDL::Value::Int.new(0o01234567)])]),
                 @parser.parse('node 0o01234567_')
    assert_raises { @parser.parse('node 0o_123') }
    assert_raises { @parser.parse('node 0o8') }
    assert_raises { @parser.parse('node 0oo') }
  end

  def test_binary
    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [::KDL::Value::Int.new(0b0101)])]),
                 @parser.parse('node 0b0101')
    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [::KDL::Value::Int.new(0b0110)])]),
                 @parser.parse('node 0b01_10')
    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [::KDL::Value::Int.new(0b0110)])]),
                 @parser.parse('node 0b01___10')
    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [::KDL::Value::Int.new(0b0110)])]),
                 @parser.parse('node 0b0110_')
    assert_raises { @parser.parse('node 0b_0110') }
    assert_raises { @parser.parse('node 0b20') }
    assert_raises { @parser.parse('node 0bb') }
  end

  def test_raw_string
    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [::KDL::Value::String.new('foo')])]),
                 @parser.parse('node r"foo"')
    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [::KDL::Value::String.new('foo\nbar')])]),
                 @parser.parse('node r"foo\nbar"')
    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [::KDL::Value::String.new('foo')])]),
                 @parser.parse('node r#"foo"#')
    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [::KDL::Value::String.new('foo')])]),
                 @parser.parse('node r##"foo"##')
    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [::KDL::Value::String.new('\nfoo\r')])]),
                 @parser.parse('node r"\nfoo\r"')
    assert_raises { @parser.parse('node r##"foo"#') }
  end

  def test_boolean
    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [::KDL::Value::Boolean.new(true)])]),
                 @parser.parse('node true')
    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [::KDL::Value::Boolean.new(false)])]),
                 @parser.parse('node false')
  end

  def test_node_space
    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [::KDL::Value::Int.new(1)])]),
                 @parser.parse('node 1')
    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [::KDL::Value::Int.new(1)])]),
                 @parser.parse("node\t1")
    assert_equal ::KDL::Document.new([::KDL::Node.new('node', [::KDL::Value::Int.new(1)])]),
                 @parser.parse("node\t \\ // hello\n 1")
  end

  def test_single_line_comment
    assert_equal ::KDL::Document.new([]), @parser.parse('//hello')
    assert_equal ::KDL::Document.new([]), @parser.parse("// \thello")
    assert_equal ::KDL::Document.new([]), @parser.parse("//hello\n")
    assert_equal ::KDL::Document.new([]), @parser.parse("//hello\r\n")
    assert_equal ::KDL::Document.new([]), @parser.parse("//hello\n\r")
    assert_equal ::KDL::Document.new([::KDL::Node.new('world')]), @parser.parse("//hello\rworld")
    assert_equal ::KDL::Document.new([::KDL::Node.new('world')]), @parser.parse("//hello\nworld\r\n")
  end

  def test_multi_line_comment
    assert_equal ::KDL::Document.new([]), @parser.parse("/*hello*/")
    assert_equal ::KDL::Document.new([]), @parser.parse("/*hello*/\n")
    assert_equal ::KDL::Document.new([]), @parser.parse("/*\nhello\r\n*/")
    assert_equal ::KDL::Document.new([]), @parser.parse("/*\nhello** /\n*/")
    assert_equal ::KDL::Document.new([]), @parser.parse("/**\nhello** /\n*/")
    assert_equal ::KDL::Document.new([::KDL::Node.new('world')]), @parser.parse('/*hello*/world')
  end

  def test_escline
    # assert_equal ::KDL::Document.new([::KDL::Node.new('foo')]), @parser.parse("\\\nfoo")
    # assert_equal ::KDL::Document.new([::KDL::Node.new('foo')]), @parser.parse("\\\n  foo")
    # assert_equal ::KDL::Document.new([::KDL::Node.new('foo')]), @parser.parse("\\  \t \nfoo")
    assert_equal ::KDL::Document.new([::KDL::Node.new('foo')]), @parser.parse("\\ // test \nfoo")
    assert_equal ::KDL::Document.new([::KDL::Node.new('foo')]), @parser.parse("\\ // test \n  foo")
  end

  def test_whitespace
    assert_equal ::KDL::Document.new([::KDL::Node.new('node')]), @parser.parse(" node")
    assert_equal ::KDL::Document.new([::KDL::Node.new('node')]), @parser.parse("\tnode")
    assert_equal ::KDL::Document.new([::KDL::Node.new('etc')]), @parser.parse("/* \nfoo\r\n */ etc")
  end

  def test_newline
    assert_equal ::KDL::Document.new([::KDL::Node.new('node1'),
                                      ::KDL::Node.new('node2')]),
                 @parser.parse("node1\nnode2")
    assert_equal ::KDL::Document.new([::KDL::Node.new('node1'),
                                      ::KDL::Node.new('node2')]),
                 @parser.parse("node1\rnode2")
    assert_equal ::KDL::Document.new([::KDL::Node.new('node1'),
                                      ::KDL::Node.new('node2')]),
                 @parser.parse("node1\r\nnode2")
    assert_equal ::KDL::Document.new([::KDL::Node.new('node1'),
                                      ::KDL::Node.new('node2')]),
                 @parser.parse("node1\n\nnode2")
  end

  def test_basic
    doc = @parser.parse('title "Hello, World"')
    nodes = nodes! {
      title "Hello, World"
    }
    assert_equal nodes, doc
  end

  def test_multiple_values
    doc = @parser.parse('bookmarks 12 15 188 1234')
    nodes = nodes! {
      bookmarks 12, 15, 188, 1234
    }
    assert_equal nodes, doc
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
    assert_equal nodes, doc
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
    assert_equal nodes, doc
  end

  def test_semicolon
    doc = @parser.parse('node1; node2; node3;')
    nodes = nodes! {
      node1; node2; node3;
    }
    assert_equal nodes, doc
  end

  def test_raw_strings
    doc = @parser.parse <<~KDL
      node "this\\nhas\\tescapes"
      other r"C:\\Users\\zkat\\"
      other-raw r#"hello"world"#
    KDL
    nodes = nodes! {
      node "this\nhas\tescapes"
      other "C:\\Users\\zkat\\"
      _ 'other-raw', "hello\"world"
    }
    assert_equal nodes, doc
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
    assert_equal nodes, doc
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
    assert_equal nodes, doc
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
    assert_equal nodes, doc
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
      mynode("not commented") {
      }
    }
    assert_equal nodes, doc
  end

  def test_multiline_nodes
    doc = @parser.parse <<~KDL
      title \\
        "Some title"

      my-node 1 2 \\  // comments are ok after \\
              3 4
    KDL
    nodes = nodes! {
      title "Some title"
      _ "my-node", 1, 2, 3, 4
    }
    assert_equal nodes, doc
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
    assert_equal nodes, doc
  end

  def test_node_names
    doc = @parser.parse <<~KDL
      "!@#$@$%Q#$%~@!40" "1.2.3" "!!!!!"=true
      foo123~!@#$%^&*.:'|?+ "weeee"
    KDL
    nodes = nodes! {
      _ "!@#$@$%Q#$%~@!40", "1.2.3", "!!!!!": true
      _ "foo123~!@#$%^&*.:'|?+", "weeee"
    }
    assert_equal nodes, doc
  end

  def test_escaping
    doc = @parser.parse <<~KDL
      node1 "\\u{1f600}"
      node2 "\\n\\t\\r\\\\\\"\\f\\b"
    KDL
    nodes = nodes! {
      node1 "😀"
      node2 "\n\t\r\\\"\f\b"
    }
    assert_equal nodes, doc
  end

  def test_node_type
    doc = @parser.parse <<~KDL
      (foo)node
    KDL
    nodes = ::KDL::Document.new([
      ::KDL::Node.new('node', type: 'foo'),
    ])
    assert_equal nodes, doc
  end

  def test_value_type
    doc = @parser.parse <<~KDL
      node (foo)"bar"
    KDL
    nodes = ::KDL::Document.new([
      ::KDL::Node.new('node', [::KDL::Value::String.new('bar', type: 'foo')]),
    ])
    assert_equal nodes, doc
  end

  def test_property_type
    doc = @parser.parse <<~KDL
      node baz=(foo)"bar"
    KDL
    nodes = ::KDL::Document.new([
      ::KDL::Node.new('node', [], { 'baz' => ::KDL::Value::String.new('bar', type: 'foo') }),
    ])
    assert_equal nodes, doc
  end

  def test_child_type
    doc = @parser.parse <<~KDL
      node {
        (foo)bar
      }
    KDL
    nodes = ::KDL::Document.new([
      ::KDL::Node.new('node', [], {}, [
        ::KDL::Node.new('bar', type: 'foo')
      ]),
    ])
    assert_equal nodes, doc
  end
end
