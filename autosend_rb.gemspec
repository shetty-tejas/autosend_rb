# frozen_string_literal: true

require_relative "lib/autosend_rb/version"

Gem::Specification.new do |spec|
  spec.name = "autosend_rb"
  spec.version = AutosendRb::VERSION
  spec.authors = ["Tejas"]
  spec.email = ["tejas.shetty@mailbox.org"]

  spec.summary = "Ruby client for Autosend"
  spec.description = spec.summary
  spec.homepage = "https://github.com/shetty-tejas/autosend_rb"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore test/ .github/ .rubocop.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "openssl"
end
