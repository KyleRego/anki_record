# frozen_string_literal: true

ANKI_PACKAGE_REGEX = /.\.apkg/.freeze
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

  describe "#new with invalid arguments" do
    context "when the name argument is nil" do
      let(:database_name) { nil }
      it "raises a ArgumentError" do
        expect { anki_database }.to raise_error ArgumentError
      end
    end

    context "when the name argument is an empty string" do
      let(:database_name) { "" }
      it "raises a ArgumentError" do
        expect { anki_database }.to raise_error ArgumentError
      end
    end

    context "when the name argument has spaces" do
      let(:database_name) { "this is invalid" }
      it "raises a ArgumentError" do
        expect { anki_database }.to raise_error ArgumentError
      end
    end

    context "when the name argument is not a string" do
      invalid_name_arguments = [[], ["a"], [1], 10, {}, { my_key: "my_value" }]
      invalid_name_arguments.each do |invalid_name|
        let(:database_name) { invalid_name }
        it "raises a ArgumentError" do
          expect { anki_database }.to raise_error ArgumentError
        end
      end
    end
  end

  describe "#new with valid arguments" do
    context "when there is no block argument" do
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

    context "when there is a block argument" do
      let(:closure_argument) do
        proc do
          # do nothing
        end
      end

      it "deletes the *.anki21 that was created" do
        anki_database
        expect(Dir.entries(".").select { |file| file.match(ANKI_COLLECTION_21_REGEX) }.count).to eq 0
      end

      it "closes the database" do
        expect(anki_database.open?).to eq false
        expect(anki_database.closed?).to eq true
      end
    end

    context "when there is a block argument that throws an error" do
      let(:closure_argument) do
        proc do
          raise "runtime error"
        end
      end

      # silence output from the rescue clause which puts the error
      before { expect($stdout).to receive(:write) }

      it "deletes the *.anki21 that was created" do
        anki_database
        expect(Dir.entries(".").select { |file| file.match(ANKI_COLLECTION_21_REGEX) }.count).to eq 0
      end

      it "closes the database" do
        expect(anki_database.open?).to eq false
        expect(anki_database.closed?).to eq true
      end
    end

    context "when there is a directory argument" do
      let(:directory_argument) { "tmp" }

      context "and no block argument" do
        it "saves one *.anki21 file in that directory" do
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
        let(:closure_argument) do
          proc do
            # do nothing
          end
        end

        it "does not save a *.anki21 file in that directory" do
          anki_database
          expect(Dir.entries(directory_argument).select { |file| file.match(ANKI_COLLECTION_21_REGEX) }.count).to eq 0
        end

        it "saves a *.apkg zip file in that directory" do
          anki_database
          expect(Dir.entries(directory_argument).select { |file| file.match(ANKI_PACKAGE_REGEX) }.count).to eq 1
        end

        it "closes the database" do
          expect(anki_database.open?).to eq false
          expect(anki_database.closed?).to eq true
        end
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
    context "with destroy_temporary_files: false" do
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
end
