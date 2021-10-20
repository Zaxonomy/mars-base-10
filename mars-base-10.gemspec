# frozen_string_literal: true

require_relative "lib/mars_base_10/version"

Gem::Specification.new do |spec|
  spec.name          = "mars-base-10"
  spec.version       = MarsBase10::VERSION
  spec.license       = "MIT"
  spec.authors       = ["Daryl Richter"]
  spec.email         = ["daryl@ngzax.com"]
  spec.homepage      = "https://www.ngzax.com"
  spec.summary       = "This is the urbit console you have been waiting for"
  spec.description   = "A keyboard maximalist, curses-based, urbit terminal ui. It uses the (also in development) ruby airlock."

  if spec.respond_to?(:metadata=)
    spec.metadata["homepage_uri"]      = spec.homepage
    spec.metadata["source_code_uri"]   = "https://github.com/Zaxonomy/mars-base-10"
    spec.metadata["changelog_uri"]     = "https://github.com/Zaxonomy/mars-base-10/CHANGELOG.md"
  end

  spec.required_ruby_version = ">= 2.7.0"

  spec.files =  Dir.glob("lib{.rb,/**/*}", File::FNM_DOTMATCH).reject {|f| File.directory?(f) }
  spec.files += %w[mars-base-10.gemspec]    # include the gemspec itself because warbler breaks w/o it

  spec.bindir        = "bin"
  spec.executables   = %w[mb10]
  spec.require_paths = ["lib"]

  spec.add_dependency "curses",     "~> 1.4"
  spec.add_dependency "pastel",     "~> 0.8"
  spec.add_dependency "sorted_set", "~> 1.0"
  spec.add_dependency "thor",       "~> 1.1"
  spec.add_dependency "tty-font",   "~> 0.5"
  spec.add_dependency "urbit-api",  "~> 0.2.1"

  spec.add_development_dependency "pry",     "~> 0.13"
  spec.add_development_dependency "rspec",   "~> 3.10"
  spec.add_development_dependency "rubocop", "~> 1.7"
end
