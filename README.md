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

KDL.parse_document(a_string) #=> KDL::Document
```

You can optionally provide your own type annotation handlers:

```ruby
KDL.parse_document(a_string, type_parsers: {
  'foo' => -> (value, type) {
    Foo.new(value.value, type: type)
  }
})
```

The `foo` proc will be called with instances of Value or Node with the type annotation `(foo)`.

Parsers are expected to have a `call` method that takes the Value or Node, and the type annotation itself, as arguments, and is expected to return either an instance of Value or Node (depending on the input type) or `nil` to return the original value as is. Take a look at [the built in parsers](lib/kdl/types) as a reference.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/danini-the-panini/kdl-rb.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
