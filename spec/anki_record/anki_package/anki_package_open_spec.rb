# frozen_string_literal: true

require "./spec/anki_record/support/anki_package_spec_helpers"

RSpec.describe AnkiRecord::AnkiPackage, ".open" do
  include_context "anki package helpers"

  context "when no file is found at the given path" do
    let(:path_to_file_to_open) { "./test/test.apkg" }

    it "throws an error" do
      described_class.new(name: "test").zip
      expect { anki_package_from_existing }.to raise_error RuntimeError
    end
  end

  context "when the given path is not to an .apkg file" do
    let(:path_to_file_to_open) { "./test.txt" }

    it "throws an error" do
      described_class.new(name: "test").zip
      expect { anki_package_from_existing }.to raise_error RuntimeError
    end
  end

  context "when not passed a block" do
    let(:path_to_file_to_open) { "./test.apkg" }

    before { described_class.new(name: "test").zip }

    it "does not save an apkg file, but saves collection.anki21, collection.anki2, and media to a temporary directory" do
      anki_package_from_existing
      expect(Dir.entries(".").count { |file| file.match(UPDATED_ANKI_PACKAGE_REGEX) }).to eq 0
      expect_num_anki21_files_in_package_tmp_directory num: 1
      expect_num_anki2_files_in_package_tmp_directory num: 1
      expect_media_file_in_tmp_directory
    end
  end

  context "when passed a block" do
    let(:path_to_file_to_open) { "./test.apkg" }
    let(:closure_argument) { proc {} }

    before { described_class.new(name: "test").zip }

    it "creates an apkg file in the current working directory and deletes the temporary directory" do
      anki_package_from_existing
      expect(Dir.entries(".").count { |file| file.match(UPDATED_ANKI_PACKAGE_REGEX) }).to eq 1
      expect_the_temporary_directory_to_not_exist
    end
  end

  context "when passed a block that throws an exception" do
    let(:path_to_file_to_open) { "./test.apkg" }
    let(:closure_argument) { proc { raise "runtime error" } }

    before { described_class.new(name: "test").zip }

    it "does not save an apkg file and also deletes the temporary directory" do
      expect { anki_package_from_existing }.to output.to_stdout
      expect_the_temporary_directory_to_not_exist
      expect(Dir.entries(".").count { |file| file.match(UPDATED_ANKI_PACKAGE_REGEX) }).to eq 0
    end
  end

  # rubocop:disable RSpec/InstanceVariable
  context "when opening an anki package with one note (2 template, 2 field note type) in a custom deck" do
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

    # rubocop:disable RSpec/ExampleLength
    it "copies the custom note type, card templates, fields, note, cards into a new collection.anki21 database" do
      expect(copied_over_note_type).to be_a AnkiRecord::NoteType
      expect(copied_over_note_type.id).to eq @original_note_type.id
      expect(copied_over_note_type.card_templates.count).to eq @original_card_templates.count
      expect(copied_over_note_type.card_templates.map(&:name).sort).to eq @original_card_templates.map(&:name).sort
      expect(copied_over_note_type.note_fields.count).to eq @original_note_fields.count
      expect(copied_over_note_type.note_fields.map(&:name).sort).to eq @original_note_fields.map(&:name).sort

      expect(copied_over_note).to be_a AnkiRecord::Note
      %w[id guid last_modified_timestamp usn tags field_contents flags data].each do |note_attribute|
        expect(copied_over_note.send(note_attribute)).to eq @original_note.send(note_attribute)
      end
      expect(copied_over_note.cards.count).to eq @original_cards.count
      expect(copied_over_note.cards.map(&:id).sort).to eq @original_cards.map(&:id).sort

      expect(new_collection_from_opened_package.models_json.keys).to include @original_note_type.id.to_s
      expect(new_collection_from_opened_package.decks_json.keys).to include @original_deck.id.to_s
    end
  end
  # rubocop:enable RSpec/ExampleLength
  # rubocop:enable RSpec/InstanceVariable
end
