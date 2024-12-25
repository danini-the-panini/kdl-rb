# frozen_string_literal: true

require "test_helper"

class KDL::V1::TokenizerTest < Minitest::Test
  def test_identifier
    assert_equal t(:IDENT, "foo"), ::KDL::V1::Tokenizer.new("foo").next_token
    assert_equal t(:IDENT, "foo-bar123"), ::KDL::V1::Tokenizer.new("foo-bar123").next_token
    assert_equal t(:IDENT, "-"), ::KDL::V1::Tokenizer.new("-").next_token
    assert_equal t(:IDENT, "--"), ::KDL::V1::Tokenizer.new("--").next_token
  end

  def test_string
    assert_equal t(:STRING, "foo"), ::KDL::V1::Tokenizer.new('"foo"').next_token
    assert_equal t(:STRING, "foo\nbar"), ::KDL::V1::Tokenizer.new('"foo\nbar"').next_token
  end

  def test_rawstring
    assert_equal t(:RAWSTRING, "foo\\nbar"), ::KDL::V1::Tokenizer.new('r"foo\\nbar"').next_token
    assert_equal t(:RAWSTRING, "foo\"bar"), ::KDL::V1::Tokenizer.new('r#"foo"bar"#').next_token
    assert_equal t(:RAWSTRING, "foo\"#bar"), ::KDL::V1::Tokenizer.new('r##"foo"#bar"##').next_token
    assert_equal t(:RAWSTRING, "\"foo\""), ::KDL::V1::Tokenizer.new('r#""foo""#').next_token

    tokenizer = ::KDL::V1::Tokenizer.new('node r"C:\\Users\\zkat\\"')
    assert_equal t(:IDENT, "node"), tokenizer.next_token
    assert_equal t(:WS, " ", 1, 5), tokenizer.next_token
    assert_equal t(:RAWSTRING, "C:\\Users\\zkat\\", 1, 6), tokenizer.next_token

    tokenizer = ::KDL::V1::Tokenizer.new('other-node r#"hello"world"#')
    assert_equal t(:IDENT, "other-node"), tokenizer.next_token
    assert_equal t(:WS, " ", 1, 11), tokenizer.next_token
    assert_equal t(:RAWSTRING, "hello\"world", 1, 12), tokenizer.next_token
  end

  def test_integer
    assert_equal t(:INTEGER, 123), ::KDL::V1::Tokenizer.new("123").next_token
    assert_equal t(:INTEGER, 0x0123456789abcdef), ::KDL::V1::Tokenizer.new("0x0123456789abcdef").next_token
    assert_equal t(:INTEGER, 0o01234567), ::KDL::V1::Tokenizer.new("0o01234567").next_token
    assert_equal t(:INTEGER, 0b101001), ::KDL::V1::Tokenizer.new("0b101001").next_token
    assert_equal t(:INTEGER, -0x0123456789abcdef), ::KDL::V1::Tokenizer.new("-0x0123456789abcdef").next_token
    assert_equal t(:INTEGER, -0o01234567), ::KDL::V1::Tokenizer.new("-0o01234567").next_token
    assert_equal t(:INTEGER, -0b101001), ::KDL::V1::Tokenizer.new("-0b101001").next_token
  end

  def test_float
    assert_equal t(:FLOAT, 1.23), ::KDL::V1::Tokenizer.new("1.23").next_token
  end

  def test_boolean
    assert_equal t(:TRUE, true), ::KDL::V1::Tokenizer.new("true").next_token
    assert_equal t(:FALSE, false), ::KDL::V1::Tokenizer.new("false").next_token
  end

  def test_null
    assert_equal t(:NULL, nil), ::KDL::V1::Tokenizer.new("null").next_token
  end

  def test_symbols
    assert_equal t(:LBRACE, '{'), ::KDL::V1::Tokenizer.new("{").next_token
    assert_equal t(:RBRACE, '}'), ::KDL::V1::Tokenizer.new("}").next_token
    assert_equal t(:EQUALS, '='), ::KDL::V1::Tokenizer.new("=").next_token
  end

  def test_whitespace
    assert_equal t(:WS, ' '), ::KDL::V1::Tokenizer.new(" ").next_token
    assert_equal t(:WS, "\t"), ::KDL::V1::Tokenizer.new("\t").next_token
    assert_equal t(:WS, "    \t"), ::KDL::V1::Tokenizer.new("    \t").next_token
  end

  def test_escline
    assert_equal t(:WS, "\\\n"), ::KDL::V1::Tokenizer.new("\\\n").next_token
    assert_equal t(:WS, "\\\n"), ::KDL::V1::Tokenizer.new("\\\n//some comment").next_token
    assert_equal t(:WS, "\\\n "), ::KDL::V1::Tokenizer.new("\\\n //some comment").next_token
    assert_equal t(:STRING, "foo"), ::KDL::V1::Tokenizer.new("\"\\\n\n\nfoo\"").next_token
  end

  def test_multiple_tokens
    tokenizer = ::KDL::V1::Tokenizer.new("node 1 \"two\" a=3")

    assert_equal t(:IDENT, 'node'), tokenizer.next_token
    assert_equal t(:WS, ' ', 1, 5), tokenizer.next_token
    assert_equal t(:INTEGER, 1, 1, 6), tokenizer.next_token
    assert_equal t(:WS, ' ', 1, 7), tokenizer.next_token
    assert_equal t(:STRING, 'two', 1, 8), tokenizer.next_token
    assert_equal t(:WS, ' ', 1, 13), tokenizer.next_token
    assert_equal t(:IDENT, 'a', 1, 14), tokenizer.next_token
    assert_equal t(:EQUALS, '=', 1, 15), tokenizer.next_token
    assert_equal t(:INTEGER, 3, 1, 16), tokenizer.next_token
    assert_equal t(:EOF, :EOF, 1, 17), tokenizer.next_token
    assert_equal eof(1, 17), tokenizer.next_token
  end

  def test_single_line_comment
    assert_equal t(:EOF, :EOF), ::KDL::V1::Tokenizer.new("// comment").next_token

    tokenizer = ::KDL::V1::Tokenizer.new <<~KDL
      node1
      // comment
      node2
    KDL

    assert_equal t(:IDENT, 'node1'), tokenizer.next_token
    assert_equal t(:NEWLINE, "\n", 1, 6), tokenizer.next_token
    assert_equal t(:NEWLINE, "\n", 2, 11), tokenizer.next_token
    assert_equal t(:IDENT, 'node2', 3, 1), tokenizer.next_token
    assert_equal t(:NEWLINE, "\n", 3, 6), tokenizer.next_token
    assert_equal t(:EOF, :EOF, 4, 1), tokenizer.next_token
    assert_equal eof(4, 1), tokenizer.next_token
  end

  def test_multiline_comment
    tokenizer = ::KDL::V1::Tokenizer.new("foo /*bar=1*/ baz=2")

    assert_equal t(:IDENT, 'foo'), tokenizer.next_token
    assert_equal t(:WS, '  ', 1, 4), tokenizer.next_token
    assert_equal t(:IDENT, 'baz', 1, 15), tokenizer.next_token
    assert_equal t(:EQUALS, '=', 1, 18), tokenizer.next_token
    assert_equal t(:INTEGER, 2, 1, 19), tokenizer.next_token
    assert_equal t(:EOF, :EOF, 1, 20), tokenizer.next_token
    assert_equal eof(1, 20), tokenizer.next_token
  end

  def test_utf8
    assert_equal t(:IDENT, '😁'), ::KDL::V1::Tokenizer.new("😁").next_token
    assert_equal t(:STRING, '😁'), ::KDL::V1::Tokenizer.new('"😁"').next_token
    assert_equal t(:IDENT, 'ノード'), ::KDL::V1::Tokenizer.new('ノード').next_token
    assert_equal t(:IDENT, 'お名前'), ::KDL::V1::Tokenizer.new('お名前').next_token
    assert_equal t(:STRING, '☜(ﾟヮﾟ☜)'), ::KDL::V1::Tokenizer.new('"☜(ﾟヮﾟ☜)"').next_token

    tokenizer = ::KDL::V1::Tokenizer.new <<~KDL
      smile "😁"
      ノード お名前="☜(ﾟヮﾟ☜)"
    KDL

    assert_equal t(:IDENT, 'smile'), tokenizer.next_token
    assert_equal t(:WS, ' ', 1, 6), tokenizer.next_token
    assert_equal t(:STRING, '😁', 1, 7), tokenizer.next_token
    assert_equal t(:NEWLINE, "\n", 1, 10), tokenizer.next_token
    assert_equal t(:IDENT, 'ノード', 2, 1), tokenizer.next_token
    assert_equal t(:WS, ' ', 2, 4), tokenizer.next_token
    assert_equal t(:IDENT, 'お名前', 2, 5), tokenizer.next_token
    assert_equal t(:EQUALS, '=', 2, 8), tokenizer.next_token
    assert_equal t(:STRING, '☜(ﾟヮﾟ☜)', 2, 9), tokenizer.next_token
    assert_equal t(:NEWLINE, "\n", 2, 18), tokenizer.next_token
    assert_equal t(:EOF, :EOF, 3, 1), tokenizer.next_token
    assert_equal eof(3, 1), tokenizer.next_token
  end

  def test_semicolon
    tokenizer = ::KDL::V1::Tokenizer.new 'node1; node2'

    assert_equal t(:IDENT, 'node1'), tokenizer.next_token
    assert_equal t(:SEMICOLON, ';', 1, 6), tokenizer.next_token
    assert_equal t(:WS, ' ', 1, 7), tokenizer.next_token
    assert_equal t(:IDENT, 'node2', 1, 8), tokenizer.next_token
    assert_equal t(:EOF, :EOF, 1, 13), tokenizer.next_token
    assert_equal eof(1, 13), tokenizer.next_token
  end

  def test_slash_dash
    tokenizer = ::KDL::V1::Tokenizer.new <<~KDL
      /-mynode /-"foo" /-key=1 /-{
        a
      }
    KDL

    assert_equal t(:SLASHDASH, '/-'), tokenizer.next_token
    assert_equal t(:IDENT, 'mynode', 1, 3), tokenizer.next_token
    assert_equal t(:WS, ' ', 1, 9), tokenizer.next_token
    assert_equal t(:SLASHDASH, '/-', 1, 10), tokenizer.next_token
    assert_equal t(:STRING, 'foo', 1, 12), tokenizer.next_token
    assert_equal t(:WS, ' ', 1, 17), tokenizer.next_token
    assert_equal t(:SLASHDASH, '/-', 1, 18), tokenizer.next_token
    assert_equal t(:IDENT, 'key', 1, 20), tokenizer.next_token
    assert_equal t(:EQUALS, '=', 1, 23), tokenizer.next_token
    assert_equal t(:INTEGER, 1, 1, 24), tokenizer.next_token
    assert_equal t(:WS, ' ', 1, 25), tokenizer.next_token
    assert_equal t(:SLASHDASH, '/-', 1, 26), tokenizer.next_token
    assert_equal t(:LBRACE, '{', 1, 28), tokenizer.next_token
    assert_equal t(:NEWLINE, "\n", 1, 29), tokenizer.next_token
    assert_equal t(:WS, '  ', 2, 1), tokenizer.next_token
    assert_equal t(:IDENT, 'a', 2, 3), tokenizer.next_token
    assert_equal t(:NEWLINE, "\n", 2, 4), tokenizer.next_token
    assert_equal t(:RBRACE, '}', 3, 1), tokenizer.next_token
    assert_equal t(:NEWLINE, "\n", 3, 2), tokenizer.next_token
    assert_equal t(:EOF, :EOF, 4, 1), tokenizer.next_token
    assert_equal eof(4, 1), tokenizer.next_token
  end

  def test_multiline_nodes
    tokenizer = ::KDL::V1::Tokenizer.new <<~KDL
      title \\
        "Some title"
    KDL

    assert_equal t(:IDENT, 'title'), tokenizer.next_token
    assert_equal t(:WS, " \\\n  ", 1, 6), tokenizer.next_token
    assert_equal t(:STRING, 'Some title', 2, 3), tokenizer.next_token
    assert_equal t(:NEWLINE, "\n", 2, 15), tokenizer.next_token
    assert_equal t(:EOF, :EOF, 3, 1), tokenizer.next_token
    assert_equal eof(3, 1), tokenizer.next_token
  end

  def test_multiline_nodes_with_comment
    tokenizer = ::KDL::V1::Tokenizer.new <<~KDL
      title \\ // some comment
        "Some title"
    KDL

    assert_equal t(:IDENT, 'title'), tokenizer.next_token
    assert_equal t(:WS, " \\ \n  ", 1, 6), tokenizer.next_token
    assert_equal t(:STRING, 'Some title', 2, 3), tokenizer.next_token
    assert_equal t(:NEWLINE, "\n", 2, 15), tokenizer.next_token
    assert_equal t(:EOF, :EOF, 3, 1), tokenizer.next_token
    assert_equal eof(3, 1), tokenizer.next_token
  end

  private

  def t(type, value, line = 1, col = 1)
    [type, ::KDL::V1::Tokenizer::Token.new(type, value, line, col)]
  end

  def eof(line = 1, col = 1)
    [false, ::KDL::V1::Tokenizer::Token.new(:EOF, :EOF, line, col)]
  end
end
