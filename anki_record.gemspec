# frozen_string_literal: true

require_relative "lib/anki_record/version"

Gem::Specification.new do |spec|
  spec.name = "anki_record"
  spec.version = AnkiRecord::VERSION
  spec.authors = ["Kyle Rego"]
  spec.email = ["regoky@outlook.com"]

  spec.summary = "Automate Anki flashcard editing with the Ruby programming language."
  spec.description = <<-DESC
  This Ruby library, which is currently in development, will provide an interface to inspect, update, and create Anki SQLite3 databases (*.apkg files).
  DESC
  spec.homepage = "https://github.com/KyleRego/anki_record"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.1"

  spec.metadata["rubygems_mfa_required"] = "true"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/KyleRego/anki_record"
  spec.metadata["changelog_uri"] = "https://github.com/KyleRego/anki_record/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rubyzip", ">= 2.3"
  spec.add_dependency "sqlite3", "~> 1.3"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
