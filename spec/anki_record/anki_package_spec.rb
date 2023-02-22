# frozen_string_literal: true

# TODO: Use consistent language in the examples

RSpec.describe AnkiRecord::AnkiPackage do
  subject(:anki_package) do
    if defined?(closure_argument) && defined?(directory_argument)
      AnkiRecord::AnkiPackage.new(name: database_name, directory: directory_argument, &closure_argument)
    elsif defined?(closure_argument)
      AnkiRecord::AnkiPackage.new(name: database_name, &closure_argument)
    elsif defined?(directory_argument)
      AnkiRecord::AnkiPackage.new(name: database_name, directory: directory_argument)
    else
      AnkiRecord::AnkiPackage.new(name: database_name)
    end
  end

  let(:database_name) { "default" }

  before(:all) { Dir.mkdir(TEST_TMP_DIRECTORY) }
  after(:all) { Dir.rmdir(TEST_TMP_DIRECTORY) }

  def tmp_directory
    anki_package.instance_variable_get(:@tmpdir)
  end

  def expect_num_anki21_files_in_package_tmp_directory(num:)
    expect(Dir.entries(tmp_directory).select { |file| file.match(ANKI_COLLECTION_21_REGEX) }.count).to eq num
  end

  def expect_num_anki2_files_in_package_tmp_directory(num:)
    expect(Dir.entries(tmp_directory).select { |file| file.match(ANKI_COLLECTION_2_REGEX) }.count).to eq num
  end

  def expect_media_file_in_tmp_directory
    expect(Dir.entries(tmp_directory).include?("media")).to eq true
  end

  def expect_num_apkg_files_in_directory(num:, directory:)
    expect(Dir.entries(directory).select { |file| file.match(ANKI_PACKAGE_REGEX) }.count).to eq num
  end

  def expect_the_temporary_directory_to_not_exist
    expect(Dir.exist?(tmp_directory)).to eq false
  end

  after { defined?(directory_argument) ? cleanup_test_files(directory: directory_argument) : cleanup_test_files(directory: ".") }

  describe "::new with invalid name arguments" do
    context "where the name argument is nil, an empty string, a string with spaces,
    or not a string (array, number, or hash)" do
      invalid_name_arguments = [nil, "", "has spaces", ["a"], 10, { my_key: "my_value" }]
      invalid_name_arguments.each do |invalid_name|
        let(:database_name) { invalid_name }
        it "raises an ArgumentError" do
          expect { anki_package }.to raise_error ArgumentError
        end
      end
    end
  end

  context "::new with no block argument" do
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
    it "saves the media file with the content '{}" do
      anki_package
      expect(File.read("#{tmp_directory}/media")).to eq "{}"
    end
    it "saves the *.anki21 file/database with the following 5 tables: cards, col, graves, notes, revlog" do
      expected_tables = %w[cards col graves notes revlog]
      result = anki_package.instance_variable_get(:@anki21_database).execute("select name from sqlite_master where type = 'table'").map do |hash|
        hash["name"]
      end.sort
      expect(result).to eq expected_tables
    end
    it "saves the *.anki21 file/database with 7 indexes:
      ix_cards_nid, ix_cards_sched, ix_cards_usn, ix_notes_csum, ix_notes_usn, ix_revlog_cid, ix_revlog_usn" do
      expected_indexes = %w[ix_cards_nid ix_cards_sched ix_cards_usn ix_notes_csum ix_notes_usn ix_revlog_cid ix_revlog_usn].sort
      result = anki_package.instance_variable_get(:@anki21_database).execute("select name from sqlite_master where type = 'index'").map do |hash|
        hash["name"]
      end.sort
      expect(result).to eq expected_indexes
    end
    it "saves the *.anki21 file/database with 1 record in the col table" do
      result = anki_package.instance_variable_get(:@anki21_database).execute("select count(*) from col").first["count(*)"]

      expect(result).to eq 1
    end
    it "does not save a *.apkg zip file" do
      anki_package
      expect_num_apkg_files_in_directory num: 0, directory: "."
    end
    it "does not close the collection.anki21 database" do
      expect(anki_package.open?).to eq true
      expect(anki_package.closed?).to eq false
    end
  end

  context "::new with a block argument" do
    let(:closure_argument) { proc {} }

    it "should delete the temporary directory" do
      expect_the_temporary_directory_to_not_exist
    end
    it "saves a *.apkg zip file" do
      anki_package
      expect_num_apkg_files_in_directory num: 1, directory: "."
    end
  end

  context "::new with a block argument that throws an error" do
    let(:closure_argument) { proc { raise "runtime error" } }

    # silence output from the rescue clause which puts the error
    before { expect($stdout).to receive(:write) }

    it "should delete the temporary directory" do
      expect_the_temporary_directory_to_not_exist
    end
    it "does not save a *.apkg zip file" do
      anki_package
      expect_num_apkg_files_in_directory num: 0, directory: "."
    end
  end

  context "::new with a directory argument" do
    let(:directory_argument) { TEST_TMP_DIRECTORY }

    context "and no block argument" do
      it "saves one *.anki21 file in the temporary directory" do
        anki_package
        expect_num_anki21_files_in_package_tmp_directory num: 1
      end
      it "saves one collection.anki2 file to a temporary directory" do
        anki_package
        expect_num_anki2_files_in_package_tmp_directory num: 1
      end
      it "does not save a *.apkg zip file" do
        anki_package
        expect_num_apkg_files_in_directory num: 0, directory: directory_argument
      end
      it "does not close the database" do
        expect(anki_package.open?).to eq true
        expect(anki_package.closed?).to eq false
      end
    end

    context "and a block argument" do
      let(:closure_argument) { proc {} }

      it "should delete the temporary directory" do
        expect_the_temporary_directory_to_not_exist
      end
      it "saves a *.apkg zip file in the specified directory" do
        anki_package
        expect_num_apkg_files_in_directory num: 1, directory: directory_argument
      end
      it "closes the database" do
        expect(anki_package.open?).to eq false
        expect(anki_package.closed?).to eq true
      end
    end
  end

  describe "#zip_and_close" do
    context "with default parameters" do
      before { anki_package.zip_and_close }

      it "should delete the temporary directory" do
        expect_the_temporary_directory_to_not_exist
      end
      it "saves one *.apkg file where * is the name argument" do
        expect(Dir.entries(".").include?("#{database_name}.apkg")).to eq true
      end
      it "closes the database" do
        expect(anki_package.open?).to eq false
        expect(anki_package.closed?).to eq true
      end
    end
  end

  subject(:anki_package_from_existing) do
    if defined?(closure_argument) && defined?(create_backup_argument)
      AnkiRecord::AnkiPackage.open(path: path_argument, create_backup: create_backup_argument, &closure_argument)
    elsif defined?(closure_argument)
      AnkiRecord::AnkiPackage.open(path: path_argument, &closure_argument)
    elsif defined?(create_backup_argument)
      AnkiRecord::AnkiPackage.open(path: path_argument, create_backup: create_backup_argument)
    else
      AnkiRecord::AnkiPackage.open(path: path_argument)
    end
  end

  describe "::open" do
    let(:path_argument) { "./test.apkg" }
    before do
      AnkiRecord::AnkiPackage.new(name: "test") do
        # set up the anki package to open
      end
    end

    describe "with an invalid path argument" do
      context "due to no file being found at the path" do
        let(:path_argument) { "./test/test.apkg" }
        it "throws error" do
          expect { anki_package_from_existing }.to raise_error RuntimeError
        end
      end
      context "due to the path not being for an *.apkg file" do
        let(:path_argument) { "./test.txt" }
        it "throws error" do
          expect { anki_package_from_existing }.to raise_error RuntimeError
        end
      end
    end

    describe "with no block argument" do
      it "creates a backup of the *.apkg file" do
        anki_package_from_existing
        expect(Dir.entries(".").select { |file| file.match(ANKI_PACKAGE_BACKUP_REGEX) }.count).to eq 1
      end
      # it "does not delete the *.anki21 file that was created by unzipping the *.apkg file"
      # it "does not save a new *.apkg zip file"
      # it "does not close the database"
    end

    context "with a block argument" do
      let(:closure_argument) { proc {} }

      it "creates a backup of the *.apkg file" do
        anki_package_from_existing
        expect(Dir.entries(".").select { |file| file.match(ANKI_PACKAGE_BACKUP_REGEX) }.count).to eq 1
      end
      # it "deletes the *.anki21 file that was created by unzipping the *.apkg file"
      # it "saves a new version of the *.apkg zip file"
      # it "closes the database"
    end

    context "with a block argument that throws an error" do
      let(:closure_argument) { proc { raise "runtime error" } }

      # silence output from the rescue clause which puts the error
      # before { expect($stdout).to receive(:write) }
      # it "creates a backup of the *.apkg file"
      # it "deletes the *.anki21 that was created by unzipping the *.apkg file"
      # it "does not save a new version of the *.apkg zip file"
      # it "closes the database"
    end

    context "with create_backup: false" do
      let(:create_backup_argument) { false }
      context "and no block argument" do
        it "does not create a backup of the *.apkg file" do
          anki_package_from_existing
          expect(Dir.entries(".").select { |file| file.match(ANKI_PACKAGE_BACKUP_REGEX) }.count).to eq 0
        end
        # it "does not delete the *.anki21 file that was created by unzipping the *.apkg file"
        # it "does not save a new version of the *.apkg zip file"
        # it "does not close the database"
      end

      context "and a block argument" do
        let(:closure_argument) { proc {} }

        it "does not create a backup of the *.apkg file" do
          anki_package_from_existing
          expect(Dir.entries(".").select { |file| file.match(ANKI_PACKAGE_BACKUP_REGEX) }.count).to eq 0
        end
        # it "deletes the *.anki21 file that was created by unzipping the *.apkg file"
        # it "saves a new version of the *.apkg zip file"
        # it "closes the database"
      end
    end
  end
end
