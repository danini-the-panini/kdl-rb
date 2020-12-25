require "test_helper"

class ExamplesTest < Minitest::Test
  def test_ci
    doc = ::KDL.parse_document(File.read(File.join(__dir__, 'examples/ci.kdl')))
    nodes = nodes! {
      name("CI")
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
            step "rustfmt", run: "cargo fmt --all -- --check"
            step "docs", run: "cargo doc --no-deps"
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
            step "Clippy", run: "cargo clippy --all -- -D warnings"
            step "Run tests", run: "cargo test --all --verbose"
          }
        }
      }
    }
    assert_equal nodes, doc
  end

  def test_cargo
    doc = ::KDL.parse_document(File.read(File.join(__dir__, 'examples/Cargo.kdl')))
    nodes = nodes! {
      package {
        name "kdl"
        version "0.0.0"
        description "kat's document language"
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

  private

  # Helper for constructing nodes
  # Basically a Ruby DSL that looks a bit like KDL
  def nodes!(&block)
    Nodes.nodes!(&block)
  end

  class Nodes < BasicObject
    attr_reader :children

    def initialize
      @children = []
    end

    def method_missing(name, *args, **kwargs, &block)
      node = ::KDL::Node.new(name,
                             args.map { |a| ::KDL::Value.from(a) },
                             kwargs.transform_keys(&:to_s)
                                   .transform_values { |a| ::KDL::Value.from(a) })
      node.children = Nodes.nodes!(&block) if block
      @children << node
    end
    alias _ method_missing

    def self.nodes!(&block)
      n = new
      n.instance_exec(&block)
      n.children
    end

    define_method(:instance_exec, ::Object.instance_method(:instance_exec))
    define_method(:block_given?, ::Object.instance_method(:block_given?))
  end
end
