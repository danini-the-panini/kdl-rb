require_relative 'lib/kdl/version'

Gem::Specification.new do |spec|
  spec.name          = "kdl"
  spec.version       = KDL::VERSION
  spec.authors       = ["Danielle Smith"]
  spec.email         = ["danini@hey.com"]

  spec.summary       = %q{KDL Document Language}
  spec.description   = %q{Ruby implementation of the KDL Document Language Spec}
  spec.homepage      = "https://kdl.dev"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/danini-the-panini/kdl-rb"
  spec.metadata["changelog_uri"] = "https://github.com/danini-the-panini/kdl-rb/releases"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end + ['lib/kdl/kdl.tab.rb']
  spec.bindir        = "exe"
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'racc', '~> 1.5'
end
