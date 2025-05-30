# frozen_string_literal: true

require "test_helper"

class ExamplesTest < Minitest::Test
  def example_path(name)
    File.join(__dir__, "kdl-org/examples/#{name}.kdl")
  end

  def test_ci
    doc = ::KDL.load_file(example_path('ci'))
    nodes = nodes! {
      name "CI"
      on "push", "pull_request"
      env {
        RUSTFLAGS("-Dwarnings")
      }
      jobs {
        fmt_and_docs("Check fmt & build docs") {
          _ "runs-on", "ubuntu-latest"
          steps {
            step uses: "actions/checkout@v1"
            step("Install Rust", uses: "actions-rs/toolchain@v1") {
              profile "minimal"
              toolchain "stable"
              components "rustfmt"
              override true
            }
            step("rustfmt") { run "cargo", "fmt", "--all", "--", "--check" }
            step("docs") { run "cargo", "doc", "--no-deps" }
          }
        }
        build_and_test("Build & Test") {
          _ "runs-on", "${{ matrix.os }}"
          strategy {
            matrix {
              rust "1.46.0", "stable"
              os "ubuntu-latest", "macOS-latest", "windows-latest"
            }
          }

          steps {
            step uses: "actions/checkout@v1"
            step("Install Rust", uses: "actions-rs/toolchain@v1") {
              profile "minimal"
              toolchain "${{ matrix.rust }}"
              components "clippy"
              override true
            }
            step("Clippy") { run "cargo", "clippy", "--all", "--", "-D", "warnings" }
            step("Run tests") { run "cargo", "test", "--all", "--verbose" }
            step "Other Stuff", run: "echo foo\necho bar\necho baz"
          }
        }
      }
    }
    assert_equal nodes, doc
  end

  def test_cargo
    doc = ::KDL.load_file(example_path('Cargo'))
    nodes = nodes! {
      package {
        name "kdl"
        version "0.0.0"
        description "The kdl document language"
        authors "Kat Marchán <kzm@zkat.tech>"
        _ "license-file", "LICENSE.md"
        edition "2018"
      }
      dependencies {
        nom "6.0.1"
        thiserror "1.0.22"
      }
    }
    assert_equal nodes, doc
  end

  def test_nuget
    doc = ::KDL.load_file(example_path('nuget'))
    # This file is particularly large. It would be nice to validate it, but for now
    # I'm just going to settle for making sure it parses.
    refute_nil doc
  end

  def test_kdl_schema
    doc = ::KDL.load_file(example_path('kdl-schema'))
    # This file is particularly large. It would be nice to validate it, but for now
    # I'm just going to settle for making sure it parses.
    refute_nil doc
  end

  def test_website
    doc = ::KDL.load_file(example_path('website'))
    # This file is particularly large. It would be nice to validate it, but for now
    # I'm just going to settle for making sure it parses.
    refute_nil doc
  end
end
