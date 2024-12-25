# frozen_string_literal: true

require "test_helper"

class URLTemplateTest < Minitest::Test
  def setup
    @variables = {
      count: ['one', 'two', 'three'],
      dom: ['example', 'com'],
      dub: 'me/too',
      hello: 'Hello World!',
      half: '50%',
      var: 'value',
      who: 'fred',
      base: 'http://example.com/home/',
      path: '/foo/bar',
      list: ['red', 'green', 'blue'],
      keys: { semi: ';', dot: '.', comma: ',' },
      v: '6',
      x: '1024',
      y: '768',
      empty: '',
      empty_keys: {},
      undef: nil,
    }
  end

  def test_no_variables
    value = KDL::Types::URLTemplate.call(::KDL::Value::String.new('https://www.example.com/foo/bar'))
    assert_equal URI('https://www.example.com/foo/bar'), value.expand({})
  end

  def test_variable
    value = KDL::Types::URLTemplate.call(::KDL::Value::String.new('https://www.example.com/{foo}/bar'))
    assert_equal URI('https://www.example.com/lorem/bar'), value.expand({ foo: 'lorem' })
  end

  def test_multiple_variables
    value = KDL::Types::URLTemplate.call(::KDL::Value::String.new('https://www.example.com/{foo}/{bar}'))
    assert_equal URI('https://www.example.com/lorem/ipsum'), value.expand({ foo: 'lorem', bar: 'ipsum' })
  end

  def test_list_expansion
    assert_expansion_equal '{count}', 'one,two,three'
    assert_expansion_equal '{count*}', 'one,two,three'
    assert_expansion_equal '{/count}', '/one,two,three'
    assert_expansion_equal '{/count*}', '/one/two/three'
    assert_expansion_equal '{;count}', ';count=one,two,three'
    assert_expansion_equal '{;count*}', ';count=one;count=two;count=three'
    assert_expansion_equal '{?count}', '?count=one,two,three'
    assert_expansion_equal '{?count*}', '?count=one&count=two&count=three'
    assert_expansion_equal '{&count*}', '&count=one&count=two&count=three'
  end

  def test_simple_string
    assert_expansion_equal '{var}', 'value'
    assert_expansion_equal '{hello}', 'Hello%20World%21'
    assert_expansion_equal '{half}', '50%25'
    assert_expansion_equal 'O{empty}X', 'OX'
    assert_expansion_equal 'O{undef}X', 'OX'
    assert_expansion_equal '{x,y}', '1024,768'
    assert_expansion_equal '{x,hello,y}', '1024,Hello%20World%21,768'
    assert_expansion_equal '?{x,empty}', '?1024,'
    assert_expansion_equal '?{x,undef}', '?1024'
    assert_expansion_equal '?{undef,y}', '?768'
    assert_expansion_equal '{var:3}', 'val'
    assert_expansion_equal '{var:30}', 'value'
    assert_expansion_equal '{list}', 'red,green,blue'
    assert_expansion_equal '{list*}', 'red,green,blue'
    assert_expansion_equal '{keys}', 'semi,%3B,dot,.,comma,%2C'
    assert_expansion_equal '{keys*}', 'semi=%3B,dot=.,comma=%2C'
  end

  def test_reserved_expansion
    assert_expansion_equal '{+var}', 'value'
    assert_expansion_equal '{+hello}', 'Hello%20World!'
    assert_expansion_equal '{+half}', '50%25'

    assert_expansion_equal '{base}index', 'http%3A%2F%2Fexample.com%2Fhome%2Findex'
    assert_expansion_equal '{+base}index', 'http://example.com/home/index'
    assert_expansion_equal 'O{+empty}X', 'OX'
    assert_expansion_equal 'O{+undef}X', 'OX'

    assert_expansion_equal '{+path}/here', '/foo/bar/here'
    assert_expansion_equal 'here?ref={+path}', 'here?ref=/foo/bar'
    assert_expansion_equal 'up{+path}{var}/here', 'up/foo/barvalue/here'
    assert_expansion_equal '{+x,hello,y}', '1024,Hello%20World!,768'
    assert_expansion_equal '{+path,x}/here', '/foo/bar,1024/here'

    assert_expansion_equal '{+path:6}/here', '/foo/b/here'
    assert_expansion_equal '{+list}', 'red,green,blue'
    assert_expansion_equal '{+list*}', 'red,green,blue'
    assert_expansion_equal '{+keys}', 'semi,;,dot,.,comma,,'
    assert_expansion_equal '{+keys*}', 'semi=;,dot=.,comma=,'
  end

  def test_fragment_expansion
    assert_expansion_equal '{#var}', '#value'
    assert_expansion_equal '{#hello}', '#Hello%20World!'
    assert_expansion_equal '{#half}', '#50%25'
    assert_expansion_equal 'foo{#empty}', 'foo#'
    assert_expansion_equal 'foo{#undef}', 'foo'
    assert_expansion_equal '{#x,hello,y}', '#1024,Hello%20World!,768'
    assert_expansion_equal '{#path,x}/here', '#/foo/bar,1024/here'
    assert_expansion_equal '{#path:6}/here', '#/foo/b/here'
    assert_expansion_equal '{#list}', '#red,green,blue'
    assert_expansion_equal '{#list*}', '#red,green,blue'
    assert_expansion_equal '{#keys}', '#semi,;,dot,.,comma,,'
    assert_expansion_equal '{#keys*}', '#semi=;,dot=.,comma=,'
  end

  def test_label_expansion
    assert_expansion_equal '{.who}', '.fred'
    assert_expansion_equal '{.who,who}', '.fred.fred'
    assert_expansion_equal '{.half,who}', '.50%25.fred'
    assert_expansion_equal 'www{.dom*}', 'www.example.com'
    assert_expansion_equal 'X{.var}', 'X.value'
    assert_expansion_equal 'X{.empty}', 'X.'
    assert_expansion_equal 'X{.undef}', 'X'
    assert_expansion_equal 'X{.var:3}', 'X.val'
    assert_expansion_equal 'X{.list}', 'X.red,green,blue'
    assert_expansion_equal 'X{.list*}', 'X.red.green.blue'
    assert_expansion_equal 'X{.keys}', 'X.semi,%3B,dot,.,comma,%2C'
    assert_expansion_equal 'X{.keys*}', 'X.semi=%3B.dot=..comma=%2C'
    assert_expansion_equal 'X{.empty_keys}', 'X'
    assert_expansion_equal 'X{.empty_keys*}', 'X'
  end

  def test_path_expansion
    assert_expansion_equal '{/who}', '/fred'
    assert_expansion_equal '{/who,who}', '/fred/fred'
    assert_expansion_equal '{/half,who}', '/50%25/fred'
    assert_expansion_equal '{/who,dub}', '/fred/me%2Ftoo'
    assert_expansion_equal '{/var}', '/value'
    assert_expansion_equal '{/var,empty}', '/value/'
    assert_expansion_equal '{/var,undef}', '/value'
    assert_expansion_equal '{/var,x}/here', '/value/1024/here'
    assert_expansion_equal '{/var:1,var}', '/v/value'
    assert_expansion_equal '{/list}', '/red,green,blue'
    assert_expansion_equal '{/list*}', '/red/green/blue'
    assert_expansion_equal '{/list*,path:4}', '/red/green/blue/%2Ffoo'
    assert_expansion_equal '{/keys}', '/semi,%3B,dot,.,comma,%2C'
    assert_expansion_equal '{/keys*}', '/semi=%3B/dot=./comma=%2C'
  end

  def test_parameter_expansion
    assert_expansion_equal '{;who}', ';who=fred'
    assert_expansion_equal '{;half}', ';half=50%25'
    assert_expansion_equal '{;empty}', ';empty'
    assert_expansion_equal '{;v,empty,who}', ';v=6;empty;who=fred'
    assert_expansion_equal '{;v,bar,who}', ';v=6;who=fred'
    assert_expansion_equal '{;x,y}', ';x=1024;y=768'
    assert_expansion_equal '{;x,y,empty}', ';x=1024;y=768;empty'
    assert_expansion_equal '{;x,y,undef}', ';x=1024;y=768'
    assert_expansion_equal '{;hello:5}', ';hello=Hello'
    assert_expansion_equal '{;list}', ';list=red,green,blue'
    assert_expansion_equal '{;list*}', ';list=red;list=green;list=blue'
    assert_expansion_equal '{;keys}', ';keys=semi,%3B,dot,.,comma,%2C'
    assert_expansion_equal '{;keys*}', ';semi=%3B;dot=.;comma=%2C'
  end

  def test_query_expansion
    assert_expansion_equal '{?who}', '?who=fred'
    assert_expansion_equal '{?half}', '?half=50%25'
    assert_expansion_equal '{?x,y}', '?x=1024&y=768'
    assert_expansion_equal '{?x,y,empty}', '?x=1024&y=768&empty='
    assert_expansion_equal '{?x,y,undef}', '?x=1024&y=768'
    assert_expansion_equal '{?var:3}', '?var=val'
    assert_expansion_equal '{?list}', '?list=red,green,blue'
    assert_expansion_equal '{?list*}', '?list=red&list=green&list=blue'
    assert_expansion_equal '{?keys}', '?keys=semi,%3B,dot,.,comma,%2C'
    assert_expansion_equal '{?keys*}', '?semi=%3B&dot=.&comma=%2C'
  end

  def test_query_continuation
    assert_expansion_equal '{&who}', '&who=fred'
    assert_expansion_equal '{&half}', '&half=50%25'
    assert_expansion_equal '?fixed=yes{&x}', '?fixed=yes&x=1024'
    assert_expansion_equal '{&x,y,empty}', '&x=1024&y=768&empty='
    assert_expansion_equal '{&x,y,undef}', '&x=1024&y=768'
    assert_expansion_equal '{&var:3}', '&var=val'
    assert_expansion_equal '{&list}', '&list=red,green,blue'
    assert_expansion_equal '{&list*}', '&list=red&list=green&list=blue'
    assert_expansion_equal '{&keys}', '&keys=semi,%3B,dot,.,comma,%2C'
    assert_expansion_equal '{&keys*}', '&semi=%3B&dot=.&comma=%2C'
  end

  private

  def assert_expansion_equal(template, expected)
    value = KDL::Types::URLTemplate.call(::KDL::Value::String.new(template))
    assert_equal(URI(expected), value.expand(@variables))
  end
end
