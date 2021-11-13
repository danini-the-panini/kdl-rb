require "test_helper"

class EmailTest < Minitest::Test
  def test_email
    value = KDL::Types::Email.call(::KDL::Value::String.new('danielle@example.com'))
    assert_equal 'danielle@example.com', value.value
    assert_equal 'danielle', value.local
    assert_equal 'example.com', value.domain

    assert_raises { KDL::Types::Email.call(::KDL::Value::String.new('not an email')) }
  end

  VALID_EMAILS = [
    ['simple@example.com', 'simple', 'example.com'],
    ['very.common@example.com', 'very.common', 'example.com'],
    ['disposable.style.email.with+symbol@example.com', 'disposable.style.email.with+symbol', 'example.com'],
    ['other.email-with-hyphen@example.com', 'other.email-with-hyphen', 'example.com'],
    ['fully-qualified-domain@example.com', 'fully-qualified-domain', 'example.com'],
    ['user.name+tag+sorting@example.com', 'user.name+tag+sorting', 'example.com'],
    ['x@example.com', 'x', 'example.com'],
    ['example-indeed@strange-example.com', 'example-indeed', 'strange-example.com'],
    ['test/test@test.com', 'test/test', 'test.com'],
    ['admin@mailserver1', 'admin', 'mailserver1'],
    ['example@s.example', 'example', 's.example'],
    ['" "@example.org', ' ', 'example.org'],
    ['"john..doe"@example.org', 'john..doe', 'example.org'],
    ['mailhost!username@example.org', 'mailhost!username', 'example.org'],
    ['user%example.com@example.org', 'user%example.com', 'example.org'],
    ['user-@example.org', 'user-', 'example.org']
  ]

  def test_valid_emails
    VALID_EMAILS.each do |email, local, domain|
      value = KDL::Types::Email.call(::KDL::Value::String.new(email))
      assert_equal email, value.value
      assert_equal local, value.local
      assert_equal domain, value.domain
    end
  end

  INVALID_EMAILS = [
    'Abc.example.com',
    'A@b@c@example.com',
    'a"b(c)d,e:f;g<h>i[j\k]l@example.com',
    'just"not"right@example.com',
    'this is"not\allowed@example.com',
    'this\ still\"not\\allowed@example.com',
    '1234567890123456789012345678901234567890123456789012345678901234+x@example.com',
    '-some-user-@-example-.com',
    'QA🦄CHOCOLATE🌈@test.com'
  ]

  def test_invalid_emails
    INVALID_EMAILS.each do |email|
      assert_raises { KDL::Types::Email.call(::KDL::Value::String.new(email)) }
    end
  end

  def test_idn_email
    value = KDL::Types::IDNEmail.call(::KDL::Value::String.new('🌈@xn--9ckb.com'))
    assert_equal '🌈@xn--9ckb.com', value.value
    assert_equal '🌈@ツッ.com', value.unicode_value
    assert_equal '🌈', value.local
    assert_equal 'ツッ.com', value.unicode_domain
    assert_equal 'xn--9ckb.com', value.domain
    value = KDL::Types::IDNEmail.call(::KDL::Value::String.new('🌈@ツッ.com'))
    assert_equal '🌈@xn--9ckb.com', value.value
    assert_equal '🌈@ツッ.com', value.unicode_value
    assert_equal '🌈', value.local
    assert_equal 'ツッ.com', value.unicode_domain
    assert_equal 'xn--9ckb.com', value.domain

    assert_raises { KDL::Types::IDNEmail.call(::KDL::Value::String.new('not an email')) }
  end
end
