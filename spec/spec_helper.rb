# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  enable_coverage :branch
end

require "anki_record"

ANKI_PACKAGE_REGEX = /.\.apkg/.freeze
ANKI_PACKAGE_BACKUP_REGEX = /.\.apkg.copy-\d/.freeze
ANKI_COLLECTION_21_REGEX = /.\.anki21/.freeze

def cleanup_test_files(directory:)
  files_created_by_tests = Dir.entries(directory).select do |file|
    file.match(ANKI_PACKAGE_REGEX) || file.match(ANKI_COLLECTION_21_REGEX)
  end
  files_created_by_tests.each { |file| File.delete("#{directory}/#{file}") }
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
