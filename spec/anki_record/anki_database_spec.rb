# frozen_string_literal: true

ANKI_PACKAGE_REGEX = /.\.apkg/.freeze
ANKI_PACKAGE_BACKUP_REGEX = /.\.apkg.copy-\d/.freeze
ANKI_COLLECTION_21_REGEX = /.\.anki21/.freeze

RSpec.describe AnkiRecord::AnkiDatabase do
  subject(:anki_database) do
    if defined?(closure_argument) && defined?(directory_argument)
      AnkiRecord::AnkiDatabase.new(name: database_name, directory: directory_argument, &closure_argument)
    elsif defined?(closure_argument)
      AnkiRecord::AnkiDatabase.new(name: database_name, &closure_argument)
    elsif defined?(directory_argument)
      AnkiRecord::AnkiDatabase.new(name: database_name, directory: directory_argument)
    else
      AnkiRecord::AnkiDatabase.new(name: database_name)
    end
  end

  let(:database_name) { "default" }

  after do
    if defined?(directory_argument)
      cleanup_test_files(directory: directory_argument)
    else
      cleanup_test_files(directory: ".")
    end
  end

  def cleanup_test_files(directory:)
    files_created_by_tests = Dir.entries(directory).select do |file|
      file.match(ANKI_PACKAGE_REGEX) || file.match(ANKI_COLLECTION_21_REGEX)
    end
    files_created_by_tests.each { |file| File.delete("#{directory}/#{file}") }
  end

  describe "::new with invalid name arguments" do
    context "where the name argument is nil, an empty string, a string with spaces,
    or not a string (array, number, or hash)" do
      invalid_name_arguments = [nil, "", "has spaces", ["a"], 10, { my_key: "my_value" }]
      invalid_name_arguments.each do |invalid_name|
        let(:database_name) { invalid_name }
        it "raises an ArgumentError" do
          expect { anki_database }.to raise_error ArgumentError
        end
      end
    end
  end

  context "::new with no block argument" do
    it "saves one *.anki21 file where * is randomly generated" do
      anki_database
      expect(Dir.entries(".").select { |file| file.match(ANKI_COLLECTION_21_REGEX) }.count).to eq 1
    end
    it "does not save a *.apkg zip file" do
      anki_database
      expect(Dir.entries(".").select { |file| file.match(ANKI_PACKAGE_REGEX) }.count).to eq 0
    end
    it "does not close the database" do
      expect(anki_database.open?).to eq true
      expect(anki_database.closed?).to eq false
    end
  end

  context "::new with a block argument" do
    let(:closure_argument) { proc {} }

    it "deletes the *.anki21 that was created" do
      anki_database
      expect(Dir.entries(".").select { |file| file.match(ANKI_COLLECTION_21_REGEX) }.count).to eq 0
    end
    it "saves a *.apkg zip file" do
      anki_database
      expect(Dir.entries(".").select { |file| file.match(ANKI_PACKAGE_REGEX) }.count).to eq 1
    end
    it "closes the database" do
      expect(anki_database.open?).to eq false
      expect(anki_database.closed?).to eq true
    end
  end

  context "::new with a block argument that throws an error" do
    let(:closure_argument) { proc { raise "runtime error" } }

    # silence output from the rescue clause which puts the error
    before { expect($stdout).to receive(:write) }

    it "deletes the *.anki21 that was created" do
      anki_database
      expect(Dir.entries(".").select { |file| file.match(ANKI_COLLECTION_21_REGEX) }.count).to eq 0
    end
    it "does not save a *.apkg zip file" do
      anki_database
      expect(Dir.entries(".").select { |file| file.match(ANKI_PACKAGE_REGEX) }.count).to eq 0
    end
    it "closes the database" do
      expect(anki_database.open?).to eq false
      expect(anki_database.closed?).to eq true
    end
  end

  context "::new with a directory argument" do
    let(:directory_argument) { "tmp" }

    context "and no block argument" do
      it "saves one *.anki21 file in the specified directory" do
        anki_database
        expect(Dir.entries(directory_argument).select { |file| file.match(ANKI_COLLECTION_21_REGEX) }.count).to eq 1
      end
      it "does not save a *.apkg zip file" do
        anki_database
        expect(Dir.entries(directory_argument).select { |file| file.match(ANKI_PACKAGE_REGEX) }.count).to eq 0
      end
      it "does not close the database" do
        expect(anki_database.open?).to eq true
        expect(anki_database.closed?).to eq false
      end
    end

    context "and a block argument" do
      let(:closure_argument) { proc {} }

      it "deletes the *.anki21 file that was created" do
        anki_database
        expect(Dir.entries(directory_argument).select { |file| file.match(ANKI_COLLECTION_21_REGEX) }.count).to eq 0
      end
      it "saves a *.apkg zip file in the specified directory" do
        anki_database
        expect(Dir.entries(directory_argument).select { |file| file.match(ANKI_PACKAGE_REGEX) }.count).to eq 1
      end
      it "closes the database" do
        expect(anki_database.open?).to eq false
        expect(anki_database.closed?).to eq true
      end
    end
  end

  describe "#zip_and_close" do
    context "with default parameters" do
      before { anki_database.zip_and_close }

      it "saves one *.apkg file where * is the name argument" do
        expect(Dir.entries(".").include?("#{database_name}.apkg")).to eq true
      end
      it "deletes any temporary files like <random_string>.anki21 files that were created" do
        expect(Dir.entries(".").select { |file| file.match(ANKI_COLLECTION_21_REGEX) }.count).to eq 0
      end
      it "closes the database" do
        expect(anki_database.open?).to eq false
        expect(anki_database.closed?).to eq true
      end
    end
    context "with a destroy_temporary_files: false argument" do
      before { anki_database.zip_and_close(destroy_temporary_files: false) }

      it "saves one *.apkg file where * is the name argument" do
        expect(Dir.entries(".").include?("#{database_name}.apkg")).to eq true
      end
      it "saves one *.anki21 file where * is randomly generated" do
        expect(Dir.entries(".").select { |file| file.match(ANKI_COLLECTION_21_REGEX) }.count).to eq 1
      end
      it "closes the database" do
        expect(anki_database.open?).to eq false
        expect(anki_database.closed?).to eq true
      end
    end
  end

  subject(:anki_database_from_existing) do
    if defined?(closure_argument) && defined?(create_backup_argument)
      AnkiRecord::AnkiDatabase.open(path: path_argument, create_backup: create_backup_argument, &closure_argument)
    elsif defined?(closure_argument)
      AnkiRecord::AnkiDatabase.open(path: path_argument, &closure_argument)
    elsif defined?(create_backup_argument)
      AnkiRecord::AnkiDatabase.open(path: path_argument, create_backup: create_backup_argument)
    else
      AnkiRecord::AnkiDatabase.open(path: path_argument)
    end
  end

  describe "::open" do
    let(:path_argument) { "./test.apkg" }
    before { AnkiRecord::AnkiDatabase.new(name: "test") { "empty_block" } }

    describe "with an invalid path argument" do
      context "due to no file being found at the path" do
        let(:path_argument) { "./test/test.apkg" }
        it "throws error" do
          expect { anki_database_from_existing }.to raise_error RuntimeError
        end
      end
      context "due to the path not being for an *.apkg file" do
        let(:path_argument) { "./test.txt" }
        it "throws error" do
          expect { anki_database_from_existing }.to raise_error RuntimeError
        end
      end
    end

    describe "with no block argument" do
      it "creates a backup of the *.apkg file" do
        anki_database_from_existing
        expect(Dir.entries(".").select { |file| file.match(ANKI_PACKAGE_BACKUP_REGEX) }.count).to eq 1
      end
      it "does not delete the *.anki21 file that was created by unzipping the *.apkg file"
      it "does not save a new *.apkg zip file"
      it "does not close the database"
    end

    context "with a block argument" do
      let(:closure_argument) { proc {} }

      it "creates a backup of the *.apkg file"
      it "deletes the *.anki21 file that was created by unzipping the *.apkg file"
      it "saves a new version of the *.apkg zip file"
      it "closes the database"
    end

    context "with a block argument that throws an error" do
      let(:closure_argument) { proc { raise "runtime error" } }

      # silence output from the rescue clause which puts the error
      # before { expect($stdout).to receive(:write) }
      it "creates a backup of the *.apkg file"
      it "deletes the *.anki21 that was created by unzipping the *.apkg file"
      it "does not save a new version of the *.apkg zip file"
      it "closes the database"
    end

    context "with create_backup: false" do
      context "and no block argument" do
        it "does not create a backup of the *.apkg file"
        it "does not delete the *.anki21 file that was created by unzipping the *.apkg file"
        it "does not save a new version of the *.apkg zip file"
        it "does not close the database"
      end

      context "and a block argument" do
        let(:closure_argument) { proc {} }

        it "does not create a backup of the *.apkg file"
        it "deletes the *.anki21 file that was created by unzipping the *.apkg file"
        it "saves a new version of the *.apkg zip file"
        it "closes the database"
      end
    end
  end
end
