# KDL

[![Gem Version](https://badge.fury.io/rb/kdl.svg)](https://badge.fury.io/rb/kdl)
[![Actions Status](https://github.com/danini-the-panini/kdl-rb/workflows/Ruby/badge.svg)](https://github.com/danini-the-panini/kdl-rb/actions)
[![Coverage Status](https://coveralls.io/repos/github/danini-the-panini/kdl-rb/badge.svg?branch=main)](https://coveralls.io/github/danini-the-panini/kdl-rb?branch=main)

This is a Ruby implementation of the [KDL Document Language](https://kdl.dev)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'kdl'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install kdl

## Usage

```ruby
require 'kdl'

KDL.parse(a_string) #=> KDL::Document
KDL.load_file('path/to/file') #=> KDL::Document
```

You can optionally provide your own type annotation handlers:

```ruby
class Foo < KDL::Value::Custom
end

KDL.parse(a_string, type_parsers: {
  'foo' => Foo
})
```

The `foo` custom type will be called with instances of Value or Node with the type annotation `(foo)`.

Custom types are expected to have a `call` method that takes the Value or Node, and the type annotation itself, as arguments, and is expected to return either an instance of `KDL::Value::Custom` or `KDL::Node::Custom` (depending on the input type) or `nil` to return the original value as is. Take a look at [the built in custom types](lib/kdl/types) as a reference.

You can also disable type annotation parsing entirely (including the built in ones):

```ruby
KDL.parse(a_string, parse_types: false)
```

## KDL v1

kdl-rb maintains backwards compatibility with the KDL v1 spec. By default, KDL will attempt to parse a file with the v1 parser if it fails to parse with v2. This behaviour can be changed by specifying the `version` option:

```ruby
KDL.parse(a_string, version: 2)
```

The resulting document will also serialize back to the same version it was parsed as. For example, if you parse a v2 document and call `to_s` on it, it will output a v2 document, and similarly with v1. This behaviour can be changed by specifying the `output_version` option:

```ruby
KDL.parse(a_string, output_version: 2)
```

This allows you to to convert documents between versions:

```ruby
KDL.parse('foo "bar" true', version: 1, output_version: 2).to_s #=> 'foo bar #true'
```

You can also convert an already parsed document between versions with `to_v1` and `to_v2`:

```ruby
doc = KDL.parse('foo "bar" true', version: 1)
doc.version #=> 1
doc.to_v2.to_s #=> 'foo bar #true'
```

You can also set the default version globally:

```ruby
KDL.default_version = 2
KDL.default_output_version = 2
```

You can still force automatic version detection with `auto_parse`:

```ruby
KDL.default_version = 2
KDL.parse('foo "bar" true') #=> Error
KDL.auto_parse('foo "bar" true') #=> KDL::V1::Document
```

Version directives are also respected:

```ruby
KDL.parse("/- kdl-version 2\nfoo bar", version: 1)
#=> Version mismatch, document specified v2, but this is a v1 parser (Racc::ParseError)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/danini-the-panini/kdl-rb.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
