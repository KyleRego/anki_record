# frozen_string_literal: true

RSpec.describe AnkiRecord::AnkiPackage do
  subject(:anki_package) do
    if defined?(closure_argument) && defined?(target_directory_argument)
      AnkiRecord::AnkiPackage.new(name: database_name, target_directory: target_directory_argument, &closure_argument)
    elsif defined?(closure_argument)
      AnkiRecord::AnkiPackage.new(name: database_name, &closure_argument)
    elsif defined?(target_directory_argument)
      AnkiRecord::AnkiPackage.new(name: database_name, target_directory: target_directory_argument)
    else
      AnkiRecord::AnkiPackage.new(name: database_name)
    end
  end

  let(:database_name) { "default" }

  before do
    # :nocov:
    # The test temporary directory might exist if RSpec was force quit/interrupted
    cleanup_test_files(directory: TEST_TMP_DIRECTORY) && Dir.rmdir(TEST_TMP_DIRECTORY) if Dir.exist?(TEST_TMP_DIRECTORY)
    # :nocov:
    Dir.mkdir(TEST_TMP_DIRECTORY)
  end

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

  after do
    if defined?(target_directory_argument) && File.directory?(target_directory_argument)
      cleanup_test_files(directory: target_directory_argument)
    else
      cleanup_test_files(directory: ".")
    end
  end

  describe "::new with invalid name arguments" do
    context "when the name argument is nil, an empty string, a string with spaces,
    or not a string (array, number, or hash)" do
      invalid_name_arguments = [nil, "", "has spaces", ["a"], 10, { my_key: "my_value" }]
      invalid_name_arguments.each do |invalid_name|
        let(:database_name) { invalid_name }
        it "should throw an ArgumentError" do
          expect { anki_package }.to raise_error ArgumentError
        end
      end
    end
  end

  describe "::new with valid name arguments" do
    context "when the name argument does not end with .apkg" do
      let(:database_name) { "test" }
      it "should zip a file with that name and .apkg appended to it" do
        anki_package.zip
        expect(File.exist?("#{database_name}.apkg")).to eq true
      end
    end
    context "when the name argument already includes .apkg" do
      let(:database_name) { "test.apkg" }
      it "should zip a file with that name" do
        anki_package.zip
        expect(File.exist?(database_name)).to eq true
      end
    end
  end

  context "::new with no block argument" do
    it "should instantiate an Anki package object with a collection attribute which is an instance of Collection" do
      expect(anki_package.collection).to be_a AnkiRecord::Collection
    end
    it "should save one collection.anki21 file to a temporary directory" do
      anki_package
      expect_num_anki21_files_in_package_tmp_directory num: 1
    end
    it "should save one collection.anki2 file to a temporary directory" do
      anki_package
      expect_num_anki2_files_in_package_tmp_directory num: 1
    end
    it "should save one file called 'media' to a temporary directory" do
      anki_package
      expect_media_file_in_tmp_directory
    end
    it "should save the media file with the content '{}'" do
      anki_package
      expect(File.read("#{tmp_directory}/media")).to eq "{}"
    end
    it "should save the temporary collection.anki21 database with with the following 5 tables: cards, col, graves, notes, revlog" do
      expected_tables = %w[cards col graves notes revlog]
      result = anki_package.instance_variable_get(:@anki21_database).prepare("select name from sqlite_master where type = 'table'").execute.map do |hash|
        hash["name"]
      end.sort
      expect(result).to eq expected_tables
    end
    it "should save the temporary collection.anki21 database with with 7 indexes:
      ix_cards_nid, ix_cards_sched, ix_cards_usn, ix_notes_csum, ix_notes_usn, ix_revlog_cid, ix_revlog_usn" do
      expected_indexes = %w[ix_cards_nid ix_cards_sched ix_cards_usn ix_notes_csum ix_notes_usn ix_revlog_cid ix_revlog_usn].sort
      result = anki_package.instance_variable_get(:@anki21_database).prepare("select name from sqlite_master where type = 'index'").execute.map do |hash|
        hash["name"]
      end.sort
      expect(result).to eq expected_indexes
    end
    it "should save the temporary collection.anki21 database with 1 record in the col table" do
      result = anki_package.instance_variable_get(:@anki21_database).prepare("select count(*) from col").execute.first["count(*)"]

      expect(result).to eq 1
    end
    it "should not save an *.apkg file" do
      anki_package
      expect_num_apkg_files_in_directory num: 0, directory: "."
    end
    it "should not close the temporary collection.anki21 database" do
      expect(anki_package.open?).to eq true
      expect(anki_package.closed?).to eq false
    end
  end

  context "::new with a block argument" do
    let(:closure_argument) { proc {} }

    it "should yield an instance of Collection to the block argument" do
      AnkiRecord::AnkiPackage.new(name: "test") do |yielded_object|
        expect(yielded_object).to be_a AnkiRecord::Collection
      end
    end

    it "should delete the temporary directory" do
      expect_the_temporary_directory_to_not_exist
    end
    it "should save one *.apkg file" do
      anki_package
      expect_num_apkg_files_in_directory num: 1, directory: "."
    end
  end

  context "::new with a block argument that throws an error" do
    let(:closure_argument) { proc { raise "runtime error" } }

    # Silence output from the rescue clause which puts the error
    before { expect($stdout).to receive(:write).at_least(:once) }

    it "should delete the temporary directory" do
      expect_the_temporary_directory_to_not_exist
    end
    it "should not save an *.apkg file" do
      anki_package
      expect_num_apkg_files_in_directory num: 0, directory: "."
    end
  end

  context "::new with a directory argument" do
    let(:target_directory_argument) { TEST_TMP_DIRECTORY }

    context "and no block argument" do
      it "should save one collection.anki21 file to a temporary directory" do
        anki_package
        expect_num_anki21_files_in_package_tmp_directory num: 1
      end
      it "should save one collection.anki2 file to a temporary directory" do
        anki_package
        expect_num_anki2_files_in_package_tmp_directory num: 1
      end
      it "should not save an *.apkg zip file" do
        anki_package
        expect_num_apkg_files_in_directory num: 0, directory: target_directory_argument
      end
      it "should not close the temporary collection.anki21 database" do
        expect(anki_package.open?).to eq true
        expect(anki_package.closed?).to eq false
      end
    end

    context "and a block argument" do
      let(:closure_argument) { proc {} }

      it "should delete the temporary directory" do
        expect_the_temporary_directory_to_not_exist
      end
      it "should save one *.apkg zip file in the specified directory" do
        anki_package
        expect_num_apkg_files_in_directory num: 1, directory: target_directory_argument
      end
    end

    context "and a block argument but the directory argument given is not a directory that exists" do
      let(:closure_argument) { proc {} }
      let(:target_directory_argument) { "does_not_exist" }

      it "should throw an error" do
        expect { anki_package }.to raise_error ArgumentError
      end
    end
  end

  describe "#zip" do
    context "with default parameters" do
      before { anki_package.zip }

      it "should delete the temporary directory" do
        expect_the_temporary_directory_to_not_exist
      end
      it "should save one *.apkg file where * is the name argument" do
        expect(Dir.entries(".").include?("#{database_name}.apkg")).to eq true
      end
    end
  end

  subject(:anki_package_from_existing) do
    if defined?(closure_argument) && defined?(target_target_directory_argument)
      AnkiRecord::AnkiPackage.open(path: path_argument, target_directory: target_target_directory_argument, &closure_argument)
    elsif defined?(closure_argument)
      AnkiRecord::AnkiPackage.open(path: path_argument, &closure_argument)
    elsif defined?(target_target_directory_argument)
      AnkiRecord::AnkiPackage.open(path: path_argument, target_directory: target_target_directory_argument)
    else
      AnkiRecord::AnkiPackage.open(path: path_argument)
    end
  end

  describe "::open" do
    let(:path_argument) { "./test.apkg" }
    before { AnkiRecord::AnkiPackage.new(name: "test").zip }

    describe "with an invalid path argument" do
      context "due to no file being found at the path" do
        let(:path_argument) { "./test/test.apkg" }
        it "should throw an error" do
          expect { anki_package_from_existing }.to raise_error RuntimeError
        end
      end
      context "due to the path not being for an *.apkg file" do
        let(:path_argument) { "./test.txt" }
        it "should throw an error" do
          expect { anki_package_from_existing }.to raise_error RuntimeError
        end
      end
    end

    describe "with no block argument" do
      context "and no target_directory argument" do
        it "should not create a new *.apkg-number file where number is the number of seconds since the epoch" do
          anki_package_from_existing
          expect(Dir.entries(".").select { |file| file.match(UPDATED_ANKI_PACKAGE_REGEX) }.count).to eq 0
        end
        it "should save one collection.anki21 file to a temporary directory" do
          anki_package_from_existing
          expect_num_anki21_files_in_package_tmp_directory num: 1
        end
        it "should save one collection.anki2 file to a temporary directory" do
          anki_package_from_existing
          expect_num_anki2_files_in_package_tmp_directory num: 1
        end
        it "should save one file called 'media' to a temporary directory" do
          anki_package_from_existing
          expect_media_file_in_tmp_directory
        end
      end
      context "and a target_directory argument" do
        let(:target_target_directory_argument) { TEST_TMP_DIRECTORY }
        it "should not create a new *.apkg-number file in the specified directory" do
          anki_package_from_existing
          expect(Dir.entries(target_target_directory_argument).select { |file| file.match(UPDATED_ANKI_PACKAGE_REGEX) }.count).to eq 0
        end
      end
    end

    context "with a block argument" do
      let(:closure_argument) { proc {} }

      context "and no target directory argument" do
        it "should delete the temporary directory" do
          expect_the_temporary_directory_to_not_exist
        end

        it "should create a new *.apkg file ending with the number of seconds since the epoch" do
          anki_package_from_existing
          expect(Dir.entries(".").select { |file| file.match(UPDATED_ANKI_PACKAGE_REGEX) }.count).to eq 1
        end
      end

      context "and a target directory argument" do
        let(:target_target_directory_argument) { TEST_TMP_DIRECTORY }
        it "should create a new *.apkg-number file in the specified directory" do
          anki_package_from_existing

          expect(Dir.entries(target_target_directory_argument).select { |file| file.match(UPDATED_ANKI_PACKAGE_REGEX) }.count).to eq 1
        end
      end
    end

    context "with a block argument that throws an error" do
      let(:closure_argument) { proc { raise "runtime error" } }

      # Silence output from the rescue clause which puts the error
      before { expect($stdout).to receive(:write).at_least(:once) }

      it "should delete the temporary directory" do
        expect_the_temporary_directory_to_not_exist
      end

      it "should not create a new *.apkg-number where number is the number of seconds since the epoch" do
        anki_package_from_existing
        expect(Dir.entries(".").select { |file| file.match(UPDATED_ANKI_PACKAGE_REGEX) }.count).to eq 0
      end
    end

    context "with a path argument to an anki package" do
      context "that has a custom note type (2 card templates, 2 note fields) and one note using it already, in a custom deck" do
        let(:path_argument) { "./crazy.apkg" }
        let(:note_type_name) { "crazy note type" }
        before do
          AnkiRecord::AnkiPackage.new(name: path_argument) do |collection|
            crazy_deck = AnkiRecord::Deck.new collection: collection, name: "Test::Deck"
            crazy_note_type = AnkiRecord::NoteType.new collection: collection, name: note_type_name
            AnkiRecord::NoteField.new note_type: crazy_note_type, name: "crazy front"
            AnkiRecord::NoteField.new note_type: crazy_note_type, name: "crazy back"
            crazy_card_template = AnkiRecord::CardTemplate.new note_type: crazy_note_type, name: "crazy card 1"
            crazy_card_template.question_format = "{{crazy front}}"
            crazy_card_template.answer_format = "{{crazy back}}"
            second_crazy_card_template = AnkiRecord::CardTemplate.new note_type: crazy_note_type, name: "crazy card 2"
            second_crazy_card_template.question_format = "{{crazy back}}"
            second_crazy_card_template.answer_format = "{{crazy front}}"
            crazy_note_type.save

            note = AnkiRecord::Note.new note_type: crazy_note_type, deck: crazy_deck
            note.crazy_front = "Hello"
            note.crazy_back = "World"
            note.save
            @original_deck = crazy_deck
            @original_note = note
            @original_cards = note.cards
            @original_note_type = crazy_note_type
            @original_card_templates = @original_note_type.card_templates
            @original_note_fields = @original_note_type.note_fields
          end
        end
        let(:copied_over_collection) { AnkiRecord::AnkiPackage.open(path: path_argument).collection }
        let(:copied_over_note_type) { copied_over_collection.find_note_type_by name: note_type_name }
        let!(:copied_over_note) { copied_over_collection.find_note_by id: @original_note.id }

        context "should copy the data from the opened package, such that in the collection object" do
          it "the custom note type is present" do
            expect(copied_over_note_type).to be_a AnkiRecord::NoteType
          end
          context "the custom note type is present" do
            it "and it has the same id as the original note type object" do
              expect(copied_over_note_type.id).to eq @original_note_type.id
            end
            it "and it has two card templates" do
              expect(copied_over_note_type.card_templates.count).to eq @original_card_templates.count
            end
            context "and it has two card templates" do
              it "that have the same names as the original card templates" do
                expect(copied_over_note_type.card_templates.map(&:name).sort).to eq @original_card_templates.map(&:name).sort
              end
            end
            it "and it has two note fields" do
              expect(copied_over_note_type.note_fields.count).to eq @original_note_fields.count
            end
            context "and it has two note fields" do
              it "that have the same names as the original note fields" do
                expect(copied_over_note_type.note_fields.map(&:name).sort).to eq @original_note_fields.map(&:name).sort
              end
            end
          end
          it "the note is present" do
            expect(copied_over_note).to be_a AnkiRecord::Note
          end
          context "the note is present" do
            it "and it has the same id, guid, last_modified_time, usn, tags, field_contents, flags, and data attributes as the original note" do
              %w[id guid last_modified_time usn tags field_contents flags data].each do |note_attribute|
                expect(copied_over_note.send(note_attribute)).to eq @original_note.send(note_attribute)
              end
            end
            it "and it has two cards" do
              expect(copied_over_note.cards.count).to eq @original_cards.count
            end
            context "and it has two cards" do
              it "that have the same ids as the original card records" do
                expect(copied_over_note.cards.map(&:id).sort).to eq @original_cards.map(&:id).sort
              end
            end
          end
        end
        context "should copy the data over from the opened package, such that in the new collection.anki21 database" do
          it "there is an id key in the models JSON object of the col record equal to the custom model id" do
            expect(copied_over_collection.models_json.keys).to include @original_note_type.id.to_s
          end
          it "there is an id key in the decks JSON object of the col record equal to the custom deck id" do
            expect(copied_over_collection.decks_json.keys).to include @original_deck.id.to_s
          end
        end
      end
    end
  end
end
