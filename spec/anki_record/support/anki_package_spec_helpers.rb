# frozen_string_literal: true

require "pry"
# rubocop:disable RSpec/ContextWording
RSpec.shared_context "anki package helpers" do
  let(:anki_package_from_existing) do
    if defined?(closure_argument) && defined?(target_directory_argument)
      described_class.open(path: path_to_file_to_open,
                           target_directory: target_directory_argument,
                          &closure_argument)
    elsif defined?(closure_argument)
      described_class.open(path: path_to_file_to_open, &closure_argument)
    elsif defined?(target_directory_argument)
      described_class.open(path: path_to_file_to_open, target_directory: target_directory_argument)
    else
      described_class.open(path: path_to_file_to_open)
    end
  end

  let(:anki_package) do
    if defined?(closure_argument) && defined?(target_directory_argument)
      described_class.new(name: new_anki_package_name, target_directory: target_directory_argument, &closure_argument)
    elsif defined?(closure_argument)
      described_class.new(name: new_anki_package_name, &closure_argument)
    elsif defined?(target_directory_argument)
      described_class.new(name: new_anki_package_name, target_directory: target_directory_argument)
    else
      described_class.new(name: new_anki_package_name)
    end
  end

  before { Dir.mkdir(TEST_TMP_DIRECTORY) }

  after do
    cleanup_test_files(directory: TEST_TMP_DIRECTORY) && Dir.rmdir(TEST_TMP_DIRECTORY)
    if defined?(target_directory_argument) && File.directory?(target_directory_argument)
      cleanup_test_files(directory: target_directory_argument)
    else
      cleanup_test_files(directory: ".")
    end
  end

  # FIXME
  def tmp_directory
    anki_package.instance_variable_get(:@tmpdir)
  rescue StandardError
    anki_package_from_existing.instance_variable_get(:@tmpdir)
  end

  def expect_num_anki21_files_in_package_tmp_directory(num:)
    expect(Dir.entries(tmp_directory).count { |file| file.match(ANKI_COLLECTION_21_REGEX) }).to eq num
  end

  def expect_num_anki2_files_in_package_tmp_directory(num:)
    expect(Dir.entries(tmp_directory).count { |file| file.match(ANKI_COLLECTION_2_REGEX) }).to eq num
  end

  def expect_media_file_in_tmp_directory
    expect(Dir.entries(tmp_directory).include?("media")).to be true
  end

  def expect_num_apkg_files_in_directory(num:, directory:)
    expect(Dir.entries(directory).count { |file| file.match(ANKI_PACKAGE_REGEX) }).to eq num
  end

  def expect_the_temporary_directory_to_not_exist
    expect(Dir.exist?(tmp_directory)).to be false
  end
end
# rubocop:enable RSpec/ContextWording
