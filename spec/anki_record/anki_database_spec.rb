# frozen_string_literal: true

require "pry"

ANKI_PACKAGE_REGEX = /.\.apkg/.freeze
ANKI_COLLECTION_21_REGEX = /.\.anki21/.freeze

RSpec.describe AnkiRecord::AnkiDatabase do
  subject(:anki_database) do
    if defined?(closure_argument)
      AnkiRecord::AnkiDatabase.new(name: database_name, &closure_argument)
    else
      AnkiRecord::AnkiDatabase.new(name: database_name)
    end
  end

  after { cleanup_test_files }

  def cleanup_test_files
    files_created_by_tests = Dir.entries(".").select do |file|
      file.match(ANKI_PACKAGE_REGEX) || file.match(ANKI_COLLECTION_21_REGEX)
    end
    files_created_by_tests.each { |file| File.delete(file) }
  end

  describe "#new" do
    context "when passed a nil name argument" do
      let(:database_name) { nil }
      it "raises a NameError" do
        expect { anki_database }.to raise_error NameError
      end
    end

    context "when passed a name with spaces" do
      let(:database_name) { "database name with spaces" }
      it "raises a NameError" do
        expect { anki_database }.to raise_error NameError
      end
    end

    context "when passed a valid name and no block argument" do
      let(:database_name) { "database_name_with_no_spaces" }

      it "saves one *.anki21 file where * is randomly generated" do
        anki_database
        expect(Dir.entries(".").select { |file| file.match(ANKI_COLLECTION_21_REGEX) }.count).to eq 1
      end
    end

    context "when passed a valid name and a block argument" do
      let(:database_name) { "hello_world" }

      let(:closure_argument) do
        @closure_given = true
        proc { puts "hello world" }
      end

      it "deletes any temporary files like <random_string>.anki21 that were created" do
        anki_database
        expect(Dir.entries(".").detect { |f| f.match(/.\.anki21/) }).to eq nil
      end
    end
  end

  describe "#zip" do
    let(:database_name) { "database_name_with_no_spaces" }

    it "saves one *.apkg file where * is the name argument" do
      anki_database.zip
      expect(Dir.entries(".").include?("database_name_with_no_spaces.apkg")).to eq true
    end
  end

  describe "#close" do
    before { @anki_database.close }

    it "closes the database" do
      # test this
    end

    it "deletes any temporary files like <random_string>.anki21 that were created" do
      AnkiRecord::AnkiDatabase.new(database_name) { puts "helo" }
      expect(Dir.entries(".").detect { |f| f.match(/.\.anki21/) }).to eq nil
    end

    context "with the delete_temporary_files: false argument" do
      before { @anki_database.close(delete_temporary_files: false) }

      it "closes the database" do
        # test this
      end

      it "does not delete the temporary files like <random_string>.anki21" do
        AnkiRecord::AnkiDatabase.new(database_name) { puts "helo" }
        expect(Dir.entries(".").detect { |f| f.match(/.\.anki21/) }).to_not eq nil
      end
    end
  end
end
