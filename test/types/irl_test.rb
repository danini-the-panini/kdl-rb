# frozen_string_literal: true

require "test_helper"

class IRLTest < Minitest::Test
  def test_irl
    value = KDL::Types::IRL.call(::KDL::Value::String.new('https://bücher.example/foo/Ῥόδος'))
    assert_equal URI('https://xn--bcher-kva.example/foo/%E1%BF%AC%CF%8C%CE%B4%CE%BF%CF%82'), value.value
    assert_equal 'https://bücher.example/foo/Ῥόδος', value.unicode_value
    value = KDL::Types::IRL.call(::KDL::Value::String.new('https://xn--bcher-kva.example/foo/%E1%BF%AC%CF%8C%CE%B4%CE%BF%CF%82'))
    assert_equal URI('https://xn--bcher-kva.example/foo/%E1%BF%AC%CF%8C%CE%B4%CE%BF%CF%82'), value.value
    assert_equal 'https://bücher.example/foo/Ῥόδος', value.unicode_value
    value = KDL::Types::IRL.call(::KDL::Value::String.new('https://bücher.example/foo/Ῥόδος?🌈=✔️#🦄'))
    assert_equal URI('https://xn--bcher-kva.example/foo/%E1%BF%AC%CF%8C%CE%B4%CE%BF%CF%82?%F0%9F%8C%88=%E2%9C%94%EF%B8%8F#%F0%9F%A6%84'), value.value
    assert_equal 'https://bücher.example/foo/Ῥόδος?🌈=✔️#🦄', value.unicode_value

    assert_raises { KDL::Types::IRL.call(::KDL::Value::String.new('not a url')) }
    assert_raises { KDL::Types::IRL.call(::KDL::Value::String.new('/reference/to/something')) }
  end

  def test_irl_reference
    value = KDL::Types::IRLReference.call(::KDL::Value::String.new('https://bücher.example/foo/Ῥόδος'))
    assert_equal URI('https://xn--bcher-kva.example/foo/%E1%BF%AC%CF%8C%CE%B4%CE%BF%CF%82'), value.value
    assert_equal 'https://bücher.example/foo/Ῥόδος', value.unicode_value
    value = KDL::Types::IRLReference.call(::KDL::Value::String.new('https://xn--bcher-kva.example/foo/%E1%BF%AC%CF%8C%CE%B4%CE%BF%CF%82'))
    assert_equal URI('https://xn--bcher-kva.example/foo/%E1%BF%AC%CF%8C%CE%B4%CE%BF%CF%82'), value.value
    assert_equal 'https://bücher.example/foo/Ῥόδος', value.unicode_value
    value = KDL::Types::IRLReference.call(::KDL::Value::String.new('/foo/Ῥόδος'))
    assert_equal URI('/foo/%E1%BF%AC%CF%8C%CE%B4%CE%BF%CF%82'), value.value
    assert_equal '/foo/Ῥόδος', value.unicode_value
    value = KDL::Types::IRLReference.call(::KDL::Value::String.new('/foo/%E1%BF%AC%CF%8C%CE%B4%CE%BF%CF%82'))
    assert_equal URI('/foo/%E1%BF%AC%CF%8C%CE%B4%CE%BF%CF%82'), value.value
    assert_equal '/foo/Ῥόδος', value.unicode_value

    assert_raises { KDL::Types::IRLReference.call(::KDL::Value::String.new('not a url reference')) }
  end
end
