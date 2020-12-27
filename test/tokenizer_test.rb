require "test_helper"

class TokenizerTest < Minitest::Test
  def test_identifier
    assert_equal [:IDENT, "foo"], ::KDL::Tokenizer.new("foo").next_token
    assert_equal [:IDENT, "foo-bar123"], ::KDL::Tokenizer.new("foo-bar123").next_token
  end

  def test_string
    assert_equal [:STRING, "foo"], ::KDL::Tokenizer.new('"foo"').next_token
    assert_equal [:STRING, "foo\nbar"], ::KDL::Tokenizer.new('"foo\nbar"').next_token
  end

  def test_rawstring
    assert_equal [:RAWSTRING, "foo"], ::KDL::Tokenizer.new('r#"foo"#').next_token
    assert_equal [:RAWSTRING, "foo\\nbar"], ::KDL::Tokenizer.new('r##"foo\nbar"##').next_token
    assert_equal [:RAWSTRING, "\"foo\""], ::KDL::Tokenizer.new('r#""foo""#').next_token
    assert_equal [:RAWSTRING, "foo\nbar"], ::KDL::Tokenizer.new(%Q(r#"foo\nbar"#)).next_token
  end

  def test_integer
    assert_equal [:INTEGER, 123], ::KDL::Tokenizer.new("123").next_token
  end

  def test_float
    assert_equal [:FLOAT, 1.23], ::KDL::Tokenizer.new("1.23").next_token
  end

  def test_boolean
    assert_equal [:TRUE, true], ::KDL::Tokenizer.new("true").next_token
    assert_equal [:FALSE, false], ::KDL::Tokenizer.new("false").next_token
  end

  def test_null
    assert_equal [:NULL, nil], ::KDL::Tokenizer.new("null").next_token
  end

  def test_symbols
    assert_equal [:LPAREN, '{'], ::KDL::Tokenizer.new("{").next_token
    assert_equal [:RPAREN, '}'], ::KDL::Tokenizer.new("}").next_token
    assert_equal [:EQUALS, '='], ::KDL::Tokenizer.new("=").next_token
  end

  def test_whitespace
    assert_equal [:WS, ' '], ::KDL::Tokenizer.new(" ").next_token
    assert_equal [:WS, "\t"], ::KDL::Tokenizer.new("\t").next_token
    assert_equal [:WS, "    \t"], ::KDL::Tokenizer.new("    \t").next_token
  end

  def test_multiple_tokens
    tokenizer = ::KDL::Tokenizer.new("node 1 \"two\" a=3")

    assert_equal([:IDENT, 'node'], tokenizer.next_token)
    assert_equal([:WS, ' '], tokenizer.next_token)
    assert_equal([:INTEGER, 1], tokenizer.next_token)
    assert_equal([:WS, ' '], tokenizer.next_token)
    assert_equal([:STRING, 'two'], tokenizer.next_token)
    assert_equal([:WS, ' '], tokenizer.next_token)
    assert_equal([:IDENT, 'a'], tokenizer.next_token)
    assert_equal([:EQUALS, '='], tokenizer.next_token)
    assert_equal([:INTEGER, 3], tokenizer.next_token)
    assert_equal([:EOF, ''], tokenizer.next_token)
    assert_equal([false, false], tokenizer.next_token)
  end

  def test_multiline_comment
    tokenizer = ::KDL::Tokenizer.new("foo /*bar=1*/ baz=2")

    assert_equal([:IDENT, 'foo'], tokenizer.next_token)
    assert_equal([:WS, '  '], tokenizer.next_token)
    assert_equal([:IDENT, 'baz'], tokenizer.next_token)
    assert_equal([:EQUALS, '='], tokenizer.next_token)
    assert_equal([:INTEGER, 2], tokenizer.next_token)
    assert_equal([:EOF, ''], tokenizer.next_token)
    assert_equal([false, false], tokenizer.next_token)
  end
end
