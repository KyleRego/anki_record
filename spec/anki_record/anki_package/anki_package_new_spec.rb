# frozen_string_literal: true

require "./spec/anki_record/support/anki_package_spec_helpers"

RSpec.describe AnkiRecord::AnkiPackage, ".new" do
  include_context "anki package helpers"

  [nil, "", "has spaces", ["a"], 10, { my_key: "my_value" }].each do |invalid_name|
    let(:new_anki_package_name) { invalid_name }

    it "throws an ArgumentError if the name argument is not a string with no spaces" do
      expect { anki_package }.to raise_error ArgumentError
    end
  end

  context "when not passed a block" do
    let(:new_anki_package_name) { "new_anki_package_file_name" }

    # rubocop:disable RSpec/ExampleLength
    it "does not save an apkg file, but saves collection.anki21, collection.anki2, and media to a temporary directory" do
      expect(anki_package.collection).to be_a AnkiRecord::Collection

      expect_num_apkg_files_in_directory num: 0, directory: "."
      expect_num_anki21_files_in_package_tmp_directory num: 1
      expect_num_anki2_files_in_package_tmp_directory num: 1
      expect_media_file_in_tmp_directory
      expect(File.read("#{tmp_directory}/media")).to eq "{}"

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

      expect(anki_package.open?).to be true
      expect(anki_package.closed?).to be false
    end

    context "when passed a directory" do
      let(:target_directory_argument) { TEST_TMP_DIRECTORY }

      it "does not save an apkg file, but saves collection.anki21, collection.anki2, and media to a temporary directory" do
        anki_package

        expect_num_anki21_files_in_package_tmp_directory num: 1
        expect_num_anki2_files_in_package_tmp_directory num: 1
        expect_media_file_in_tmp_directory
        expect_num_apkg_files_in_directory num: 0, directory: target_directory_argument
        expect(anki_package.open?).to be true
        expect(anki_package.closed?).to be false
      end
    end
    # rubocop:enable RSpec/ExampleLength
  end

  describe "when passed a block" do
    let(:new_anki_package_name) { "new_anki_package_file_name" }
    let(:closure_argument) { proc {} }

    it "yields an instance of Collection to the block argument" do
      described_class.new(name: "test") do |yielded_object|
        expect(yielded_object).to be_a AnkiRecord::Collection
      end
    end

    it "saves an apkg file and deletes the temporary directory" do
      expect_the_temporary_directory_to_not_exist
      expect_num_apkg_files_in_directory num: 1, directory: "."
    end

    context "when passed a directory that exists" do
      let(:target_directory_argument) { TEST_TMP_DIRECTORY }

      it "deletes the temporary directory and saves one *.apkg zip file in the specified directory" do
        anki_package
        expect_the_temporary_directory_to_not_exist
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
    let(:new_anki_package_name) { "new_anki_package_file_name" }
    let(:closure_argument) { proc { raise "runtime error" } }

    it "does not save an apkg file and also deletes the temporary directory" do
      expect { anki_package }.to output.to_stdout
      expect_num_apkg_files_in_directory num: 0, directory: "."
      expect_the_temporary_directory_to_not_exist
    end
  end
end
