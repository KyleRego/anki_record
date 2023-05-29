# frozen_string_literal: true

RSpec.shared_context "when there is a directory for the test" do
  before { Dir.mkdir(TEST_TMP_DIRECTORY) }

  after do
    cleanup_test_files(directory: TEST_TMP_DIRECTORY) && Dir.rmdir(TEST_TMP_DIRECTORY)
  end
end
