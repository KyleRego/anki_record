# frozen_string_literal: true

require "./spec/anki_record/support/test_directory"

def expect_num_anki21_files_in_tmpdir(num:)
  expect(Dir.entries(anki_package.tmpdir).count do |file|
    file.match(ANKI_COLLECTION_21_REGEX)
  end).to eq num
end

def expect_num_anki2_files_in_tmpdir(num:)
  expect(Dir.entries(anki_package.tmpdir).count do |file|
    file.match(ANKI_COLLECTION_2_REGEX)
  end).to eq num
end

def expect_num_apkg_files_in_directory(num:, directory:)
  expect(Dir.entries(directory).count do |file|
    file.match(ANKI_PACKAGE_REGEX)
  end).to eq num
end

RSpec.describe AnkiRecord::AnkiPackage, ".create" do
  let(:anki_package) do
    if defined?(closure_argument) && defined?(target_directory_argument)
      described_class.create(name: create_anki_package_name, target_directory: target_directory_argument, &closure_argument)
    elsif defined?(closure_argument)
      described_class.create(name: create_anki_package_name, &closure_argument)
    elsif defined?(target_directory_argument)
      described_class.create(name: create_anki_package_name, target_directory: target_directory_argument)
    else
      described_class.create(name: create_anki_package_name)
    end
  end

  after { cleanup_test_files(directory: ".") }

  describe "with invalid argument" do
    [nil, "", "has spaces", ["a"], 10, { my_key: "my_value" }].each do |invalid_name|
      let(:create_anki_package_name) { invalid_name }

      it "throws an ArgumentError if the name argument is not a string with no spaces" do
        expect { anki_package }.to raise_error ArgumentError
      end
    end
  end

  context "when not passed a block" do
    let(:create_anki_package_name) { "create_anki_package_file_name" }

    # rubocop:disable RSpec/ExampleLength
    it "does not save an apkg file, but saves collection.anki21, collection.anki2, and media to a temporary directory" do
      expect(anki_package.anki21_database).to be_a AnkiRecord::Anki21Database

      expect_num_apkg_files_in_directory num: 0, directory: "."
      expect_num_anki21_files_in_tmpdir num: 1
      expect_num_anki2_files_in_tmpdir num: 1
      expect(Dir.entries(anki_package.tmpdir).include?("media")).to be true
      expect(File.read("#{anki_package.tmpdir}/media")).to eq "{}"

      expected_tables = %w[cards col graves notes revlog]
      anki_21_db_tables = anki_package.anki21_database.prepare("select name from sqlite_master where type = 'table'").execute.map do |hash|
        hash["name"]
      end.sort
      expect(anki_21_db_tables).to eq expected_tables

      expected_indexes = %w[ix_cards_nid ix_cards_sched ix_cards_usn ix_notes_csum ix_notes_usn ix_revlog_cid ix_revlog_usn].sort
      anki_21_db_indexes = anki_package.anki21_database.prepare("select name from sqlite_master where type = 'index'").execute.map do |hash|
        hash["name"]
      end.sort
      expect(anki_21_db_indexes).to eq expected_indexes

      col_records_count = anki_package.anki21_database.prepare("select count(*) from col").execute.first["count(*)"]
      expect(col_records_count).to eq 1
    end

    context "when passed a directory" do
      include_context "when there is a directory for the test"
      let(:target_directory_argument) { TEST_TMP_DIRECTORY }

      it "does not save an apkg file, but saves collection.anki21, collection.anki2, and media to a temporary directory" do
        anki_package

        expect_num_anki21_files_in_tmpdir num: 1
        expect_num_anki2_files_in_tmpdir num: 1
        expect(Dir.entries(anki_package.tmpdir).include?("media")).to be true
        expect_num_apkg_files_in_directory num: 0, directory: target_directory_argument
      end
    end
    # rubocop:enable RSpec/ExampleLength
  end

  describe "when passed a block" do
    let(:create_anki_package_name) { "create_anki_package_file_name" }
    let(:closure_argument) { proc {} }

    it "yields an Anki21Database object to the block argument" do
      described_class.create(name: "test") do |anki21_database|
        expect(anki21_database).to be_a AnkiRecord::Anki21Database
      end
    end

    it "saves an apkg file and deletes the temporary directory" do
      expect(Dir.exist?(anki_package.tmpdir)).to be false
      expect_num_apkg_files_in_directory num: 1, directory: "."
    end

    context "when passed a directory that exists" do
      include_context "when there is a directory for the test"
      let(:target_directory_argument) { TEST_TMP_DIRECTORY }

      it "deletes the temporary directory and saves one *.apkg zip file in the specified directory" do
        anki_package
        expect(Dir.exist?(anki_package.tmpdir)).to be false
        expect_num_apkg_files_in_directory num: 1, directory: target_directory_argument
      end
    end

    context "when passed a directory that does not exist" do
      let(:target_directory_argument) { "does_not_exist" }

      it "throws an error" do
        expect { anki_package }.to raise_error ArgumentError
      end
    end
  end

  context "when passed a block that throws an exception" do
    let(:create_anki_package_name) { "create_anki_package_file_name" }
    let(:closure_argument) { proc { raise "runtime error" } }

    it "does not save an apkg file and also deletes the temporary directory" do
      expect { anki_package }.to output.to_stdout
      expect_num_apkg_files_in_directory num: 0, directory: "."
      expect(Dir.exist?(anki_package.tmpdir)).to be false
    end
  end
end
