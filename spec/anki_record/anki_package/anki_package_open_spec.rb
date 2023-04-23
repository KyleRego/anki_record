# frozen_string_literal: true

require "./spec/anki_record/support/anki_package_spec_helpers"

RSpec.describe AnkiRecord::AnkiPackage, ".open" do
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

  describe "with invalid path argument" do
    before { described_class.new(name: "test").zip }

    context "when no file is found at the given path" do
      let(:path_to_file_to_open) { "./test/test.apkg" }

      it "throws an error" do
        expect { anki_package_from_existing }.to raise_error RuntimeError
      end
    end

    context "when the given path is not to an .apkg file" do
      let(:path_to_file_to_open) { "./test.txt" }

      it "throws an error" do
        expect { anki_package_from_existing }.to raise_error RuntimeError
      end
    end
  end

  describe "with no block argument" do
    let(:path_to_file_to_open) { "./test.apkg" }
    let(:new_anki_package_name) { "new_anki_package_file_name" }

    before { described_class.new(name: "test").zip }

    context "with no target_directory argument" do
      it "does not create a new *.apkg-number file where number is the number of seconds since the epoch" do
        anki_package_from_existing
        expect(Dir.entries(".").select { |file| file.match(UPDATED_ANKI_PACKAGE_REGEX) }.count).to eq 0
      end

      it "saves one collection.anki21 file to a temporary directory" do
        anki_package_from_existing
        expect_num_anki21_files_in_package_tmp_directory num: 1
      end

      it "saves one collection.anki2 file to a temporary directory" do
        anki_package_from_existing
        expect_num_anki2_files_in_package_tmp_directory num: 1
      end

      it "saves one file called 'media' to a temporary directory" do
        anki_package_from_existing
        expect_media_file_in_tmp_directory
      end
    end
  end

  describe "with a target_directory argument" do
    let(:path_to_file_to_open) { "./test.apkg" }
    let(:target_target_directory_argument) { TEST_TMP_DIRECTORY }

    before { described_class.new(name: "test").zip }

    it "does not create a new *.apkg-number file in the specified directory" do
      anki_package_from_existing
      expect(Dir.entries(target_target_directory_argument).select { |file| file.match(UPDATED_ANKI_PACKAGE_REGEX) }.count).to eq 0
    end
  end

  describe "with a block argument" do
    let(:path_to_file_to_open) { "./test.apkg" }
    let(:new_anki_package_name) { "new_anki_package_file_name" }
    let(:closure_argument) { proc {} }

    before { described_class.new(name: "test").zip }

    context "with no target directory argument" do
      it "deletes the temporary directory" do
        expect_the_temporary_directory_to_not_exist
      end

      it "creates a new *.apkg file ending with the number of seconds since the epoch" do
        anki_package_from_existing
        expect(Dir.entries(".").select { |file| file.match(UPDATED_ANKI_PACKAGE_REGEX) }.count).to eq 1
      end
    end
  end

  describe "with a block argument and target directory argument" do
    before { described_class.new(name: "test").zip }

    let(:path_to_file_to_open) { "./test.apkg" }
    let(:closure_argument) { proc {} }
    let(:target_target_directory_argument) { TEST_TMP_DIRECTORY }

    it "creates a new *.apkg-number file in the specified directory" do
      anki_package_from_existing
      expect(Dir.entries(target_target_directory_argument).select { |file| file.match(UPDATED_ANKI_PACKAGE_REGEX) }.count).to eq 1
    end
  end

  describe "with a block argument that throws an error" do
    let(:path_to_file_to_open) { "./test.apkg" }
    let(:new_anki_package_name) { "new_anki_package_file_name" }
    let(:closure_argument) { proc { raise "runtime error" } }

    before do
      described_class.new(name: "test").zip
      # Silence output from the rescue clause which puts the error
      # rubocop:disable RSpec/ExpectInHook
      # rubocop:disable RSpec/MessageSpies
      expect($stdout).to receive(:write).at_least(:once)
      # rubocop:enable RSpec/MessageSpies
      # rubocop:enable RSpec/ExpectInHook
    end

    it "deletes the temporary directory" do
      expect_the_temporary_directory_to_not_exist
    end

    it "does not create a new *.apkg-number where number is the number of seconds since the epoch" do
      anki_package_from_existing
      expect(Dir.entries(".").select { |file| file.match(UPDATED_ANKI_PACKAGE_REGEX) }.count).to eq 0
    end
  end

  # rubocop:disable RSpec/InstanceVariable
  describe "with an anki package with one note (2 template, 2 field note type) in a custom deck" do
    let(:path_to_file_to_open) { "./package_to_open.apkg" }
    let(:new_collection_from_opened_package) { described_class.open(path: path_to_file_to_open).collection }
    let(:copied_over_note_type) { new_collection_from_opened_package.find_note_type_by name: note_type_name }
    let(:copied_over_note) { new_collection_from_opened_package.find_note_by id: @original_note.id }
    let(:note_type_name) { "crazy note type" }

    before do
      described_class.new(name: path_to_file_to_open) do |collection|
        custom_deck = AnkiRecord::Deck.new collection: collection, name: "Test::Deck"
        custom_deck.save
        custom_note_type = AnkiRecord::NoteType.new collection: collection, name: note_type_name
        AnkiRecord::NoteField.new note_type: custom_note_type, name: "crazy front"
        AnkiRecord::NoteField.new note_type: custom_note_type, name: "crazy back"
        custom_template = AnkiRecord::CardTemplate.new note_type: custom_note_type, name: "crazy card 1"
        custom_template.question_format = "{{crazy front}}"
        custom_template.answer_format = "{{crazy back}}"
        second_custom_template = AnkiRecord::CardTemplate.new note_type: custom_note_type, name: "crazy card 2"
        second_custom_template.question_format = "{{crazy back}}"
        second_custom_template.answer_format = "{{crazy front}}"
        custom_note_type.save

        note = AnkiRecord::Note.new note_type: custom_note_type, deck: custom_deck
        note.crazy_front = "Hello"
        note.crazy_back = "World"
        note.save
        @original_deck = custom_deck
        @original_note = note
        @original_cards = note.cards
        @original_note_type = custom_note_type
        @original_card_templates = @original_note_type.card_templates
        @original_note_fields = @original_note_type.note_fields
      end
    end

    anki_package_open_integration_test = <<-DESC
      copies the data from the opened package such that in the new collection
        1a. the custom note type is present
        1b. the custom note type has the same id as the original note type object
        1c. the custom note type has two card templates
        1d. the custom note type has two card templates with the same names as the original card templates
        1e. the custom note type has two note fields
        1f. the custom note type has two note fields with the same names as the original note fields

        2a. the note is present
        2b. the note has the same id, guid, last_modified_timestamp, usn, tags, field_contents, flags, and data attributes as the original note
        2c. the note has has two cards
        2d. the note has two cards with the same ids as the original card records

      copies the data from the opened package such that in the new collection.anki21 database
        3a. there is an id key in the models JSON object of the col record equal to the custom model id
        3b. there is an id key in the decks JSON object of the col record equal to the custom deck id
    DESC

    # rubocop:disable RSpec/ExampleLength
    it(anki_package_open_integration_test) do
      # 1a
      expect(copied_over_note_type).to be_a AnkiRecord::NoteType
      # 1b
      expect(copied_over_note_type.id).to eq @original_note_type.id
      # 1c
      expect(copied_over_note_type.card_templates.count).to eq @original_card_templates.count
      # 1d
      expect(copied_over_note_type.card_templates.map(&:name).sort).to eq @original_card_templates.map(&:name).sort
      # 1e
      expect(copied_over_note_type.note_fields.count).to eq @original_note_fields.count
      # 1f
      expect(copied_over_note_type.note_fields.map(&:name).sort).to eq @original_note_fields.map(&:name).sort

      # 2a
      expect(copied_over_note).to be_a AnkiRecord::Note
      # 2b
      %w[id guid last_modified_timestamp usn tags field_contents flags data].each do |note_attribute|
        expect(copied_over_note.send(note_attribute)).to eq @original_note.send(note_attribute)
      end
      # 2c
      expect(copied_over_note.cards.count).to eq @original_cards.count
      # 2d
      expect(copied_over_note.cards.map(&:id).sort).to eq @original_cards.map(&:id).sort

      # 3a
      expect(new_collection_from_opened_package.models_json.keys).to include @original_note_type.id.to_s
      # 3b
      expect(new_collection_from_opened_package.decks_json.keys).to include @original_deck.id.to_s
    end
  end
  # rubocop:enable RSpec/ExampleLength
  # rubocop:enable RSpec/InstanceVariable
end
