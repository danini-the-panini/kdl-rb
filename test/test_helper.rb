# frozen_string_literal: true

require "simplecov"
require "coveralls"
SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "kdl"

require "minitest/autorun"
