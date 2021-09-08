# frozen_string_literal: true

require_relative "lib/mars_base_10/version"

Gem::Specification.new do |spec|
  spec.name          = "mars-base-10"
  spec.version       = MarsBase10::VERSION
  spec.authors       = ["Daryl Richter"]
  spec.email         = ["daryl@ngzax.com"]

  spec.summary       = "This is the urbit console you have been waiting for"
  spec.description   = "A keyboard maximalist, curses-based, urbit terminal ui. It uses the (also in development) ruby airlock."
  spec.homepage      = "https://www.ngzax.com"
  spec.license       = "MIT"

  spec.required_ruby_version = ">= 3.0.2"

  spec.metadata["allowed_push_host"] = "TODO: Set to 'https://mygemserver.com'"
  spec.metadata["homepage_uri"]      = spec.homepage
  spec.metadata["source_code_uri"]   = "https://github.com/Zaxonomy/mars-base-10"
  spec.metadata["changelog_uri"]     = "https://github.com/Zaxonomy/mars-base-10/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end

  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.files         = `git ls-files -z`.split("\x0")
  spec.require_paths = ["lib"]

  spec.add_dependency "curses",    "~> 1.4"
  spec.add_dependency "urbit-api", "~> 0.2"

  spec.add_development_dependency "pry",     "~> 0.13"
  spec.add_development_dependency "rspec",   "~> 3.10"
  spec.add_development_dependency "rubocop", "~> 1.7"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
