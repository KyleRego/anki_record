# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  enable_coverage :branch
end

require "anki_record"

ANKI_PACKAGE_REGEX = /.\.apkg$/
UPDATED_ANKI_PACKAGE_REGEX = /.-\d+\.apkg$/
ANKI_COLLECTION_21_REGEX = /collection\.anki21$/
ANKI_COLLECTION_2_REGEX = /collection\.anki2$/

TEST_TMP_DIRECTORY = "tests_tmp"

def cleanup_test_files(directory:)
  files_created_by_tests = Dir.entries(directory).select do |file|
    file.match(ANKI_PACKAGE_REGEX) || file.match(UPDATED_ANKI_PACKAGE_REGEX)
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
