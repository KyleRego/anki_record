# frozen_string_literal: true

require "./spec/anki_record/support/anki_package_spec_helpers"

RSpec.describe AnkiRecord::AnkiPackage, ".new" do
  include_context "anki package helpers"

  describe "with invalid name arguments" do
    context "when the name argument is nil, an empty string, a string with spaces,
    or not a string (array, number, or hash)" do
      invalid_name_arguments = [nil, "", "has spaces", ["a"], 10, { my_key: "my_value" }]
      invalid_name_arguments.each do |invalid_name|
        let(:new_anki_package_name) { invalid_name }
        it "throws an ArgumentError" do
          expect { anki_package }.to raise_error ArgumentError
        end
      end
    end
  end

  describe "with valid name arguments" do
    context "when the name argument does not end with .apkg" do
      let(:new_anki_package_name) { "test" }

      it "zips a file with that name and .apkg appended to it" do
        anki_package.zip
        expect(File.exist?("#{new_anki_package_name}.apkg")).to be true
      end
    end

    context "when the name argument already includes .apkg" do
      let(:new_anki_package_name) { "test.apkg" }

      it "zips a file with that name" do
        anki_package.zip
        expect(File.exist?(new_anki_package_name)).to be true
      end
    end
  end

  describe "with no block argument" do
    let(:new_anki_package_name) { "new_anki_package_file_name" }

    it "instantiates an Anki package object with a collection attribute which is an instance of Collection" do
      expect(anki_package.collection).to be_a AnkiRecord::Collection
    end

    it "saves one collection.anki21 file to a temporary directory" do
      anki_package
      expect_num_anki21_files_in_package_tmp_directory num: 1
    end

    it "saves one collection.anki2 file to a temporary directory" do
      anki_package
      expect_num_anki2_files_in_package_tmp_directory num: 1
    end

    it "saves one file called 'media' to a temporary directory" do
      anki_package
      expect_media_file_in_tmp_directory
    end

    it "saves the media file with the content '{}'" do
      anki_package
      expect(File.read("#{tmp_directory}/media")).to eq "{}"
    end

    it "saves the temporary collection.anki21 database with with the following 5 tables: cards, col, graves, notes, revlog" do
      expected_tables = %w[cards col graves notes revlog]
      result = anki_package.instance_variable_get(:@anki21_database).prepare("select name from sqlite_master where type = 'table'").execute.map do |hash|
        hash["name"]
      end.sort
      expect(result).to eq expected_tables
    end

    it "saves the temporary collection.anki21 database with with 7 indexes: ix_cards_nid, ix_cards_sched, ix_cards_usn, ix_notes_csum, ix_notes_usn, ix_revlog_cid, ix_revlog_usn" do
      expected_indexes = %w[ix_cards_nid ix_cards_sched ix_cards_usn ix_notes_csum ix_notes_usn ix_revlog_cid ix_revlog_usn].sort
      result = anki_package.instance_variable_get(:@anki21_database).prepare("select name from sqlite_master where type = 'index'").execute.map do |hash|
        hash["name"]
      end.sort
      expect(result).to eq expected_indexes
    end

    it "saves the temporary collection.anki21 database with 1 record in the col table" do
      result = anki_package.instance_variable_get(:@anki21_database).prepare("select count(*) from col").execute.first["count(*)"]

      expect(result).to eq 1
    end

    it "does not save an *.apkg file" do
      anki_package
      expect_num_apkg_files_in_directory num: 0, directory: "."
    end

    it "does not close the temporary collection.anki21 database" do
      expect(anki_package.open?).to be true
      expect(anki_package.closed?).to be false
    end
  end

  describe "with a block argument" do
    let(:new_anki_package_name) { "new_anki_package_file_name" }
    let(:closure_argument) { proc {} }

    it "yields an instance of Collection to the block argument" do
      described_class.new(name: "test") do |yielded_object|
        expect(yielded_object).to be_a AnkiRecord::Collection
      end
    end

    it "deletes the temporary directory" do
      expect_the_temporary_directory_to_not_exist
    end

    it "saves one *.apkg file" do
      anki_package
      expect_num_apkg_files_in_directory num: 1, directory: "."
    end
  end

  describe "with a block argument that throws an error" do
    let(:new_anki_package_name) { "new_anki_package_file_name" }
    let(:closure_argument) { proc { raise "runtime error" } }

    # Silence output from the rescue clause which puts the error
    # rubocop:disable RSpec/ExpectInHook
    # rubocop:disable RSpec/MessageSpies
    before { expect($stdout).to receive(:write).at_least(:once) }
    # rubocop:enable RSpec/MessageSpies
    # rubocop:enable RSpec/ExpectInHook

    it "deletes the temporary directory" do
      expect_the_temporary_directory_to_not_exist
    end

    it "does not save an *.apkg file" do
      anki_package
      expect_num_apkg_files_in_directory num: 0, directory: "."
    end
  end

  describe "with a directory argument" do
    let(:new_anki_package_name) { "new_anki_package_file_name" }
    let(:target_directory_argument) { TEST_TMP_DIRECTORY }

    context "with no block argument" do
      it "saves one collection.anki21 file to a temporary directory" do
        anki_package
        expect_num_anki21_files_in_package_tmp_directory num: 1
      end

      it "saves one collection.anki2 file to a temporary directory" do
        anki_package
        expect_num_anki2_files_in_package_tmp_directory num: 1
      end

      it "does not save an *.apkg zip file" do
        anki_package
        expect_num_apkg_files_in_directory num: 0, directory: target_directory_argument
      end

      it "does not close the temporary collection.anki21 database" do
        expect(anki_package.open?).to be true
        expect(anki_package.closed?).to be false
      end
    end

    context "with a block argument" do
      let(:closure_argument) { proc {} }

      it "deletes the temporary directory" do
        expect_the_temporary_directory_to_not_exist
      end

      it "saves one *.apkg zip file in the specified directory" do
        anki_package
        expect_num_apkg_files_in_directory num: 1, directory: target_directory_argument
      end
    end

    context "with a block argument but the directory argument given is not a directory that exists" do
      let(:closure_argument) { proc {} }
      let(:target_directory_argument) { "does_not_exist" }

      it "throws an error" do
        expect { anki_package }.to raise_error ArgumentError
      end
    end
  end
end
