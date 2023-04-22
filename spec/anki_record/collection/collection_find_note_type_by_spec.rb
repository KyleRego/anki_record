# frozen_string_literal: true

require "./spec/anki_record/support/collection_spec_helpers"

RSpec.describe AnkiRecord::Collection, "#find_note_type_by" do
  include_context "collection shared helpers"

  context "when passed both name and id arguments" do
    it "throws an ArgumentError" do
      expect { collection.find_note_type_by(name: "name", id: "id") }.to raise_error ArgumentError
    end
  end

  context "when passed neither a name nor an id argument" do
    it "throws an ArgumentError" do
      expect { collection.find_note_type_by }.to raise_error ArgumentError
    end
  end

  context "when passed a name argument where the collection does not have a note type with that name" do
    it "returns nil" do
      expect(collection.find_note_type_by(name: "no-note-type-with-this-name")).to be_nil
    end
  end

  context "when passed a name argument where the collection has a note type with that name" do
    it "returns a note type object" do
      expect(collection.find_note_type_by(name: "Basic").instance_of?(AnkiRecord::NoteType)).to be true
    end

    it "returns a note type object with name equal to the name argument" do
      expect(collection.find_note_type_by(name: "Basic").name).to eq "Basic"
    end
  end

  context "when passed an id argument where the collection does not have a note type with that id" do
    it "returns nil" do
      expect(collection.find_note_type_by(id: "1234")).to be_nil
    end
  end

  context "when passed an id argument where the collection has a note type with that id" do
    let(:basic_note_type_id) { collection.find_note_type_by(name: "Basic").id }

    it "returns a note type object" do
      expect(collection.find_note_type_by(id: basic_note_type_id).instance_of?(AnkiRecord::NoteType)).to be true
    end

    it "returns a note type object with name equal to the name argument" do
      expect(collection.find_note_type_by(id: basic_note_type_id).id).to eq basic_note_type_id
    end
  end

  context "when the note type exists in the opened Anki package but not the current collection.anki21 database" do
    let(:package_to_open_name) { "package_to_open_for_test" }
    let(:collection_instantiated_from_open) { AnkiRecord::AnkiPackage.open(path: "#{package_to_open_name}.apkg").collection }
    let(:note_type_name) { "custom note type in opened package" }

    # rubocop:disable RSpec/InstanceVariable
    before do
      AnkiRecord::AnkiPackage.new(name: package_to_open_name) do |collection|
        default_deck = collection.find_deck_by name: "Default"
        opened_note_type = AnkiRecord::NoteType.new collection: collection, name: note_type_name
        AnkiRecord::NoteField.new note_type: opened_note_type, name: "opened front"
        AnkiRecord::NoteField.new note_type: opened_note_type, name: "opened back"
        opened_card_template = AnkiRecord::CardTemplate.new note_type: opened_note_type, name: "opened card 1"
        opened_card_template.question_format = "{{opened front}}"
        opened_card_template.answer_format = "{{opened back}}"
        second_opened_card_template = AnkiRecord::CardTemplate.new note_type: opened_note_type, name: "opened card 2"
        second_opened_card_template.question_format = "{{opened back}}"
        second_opened_card_template.answer_format = "{{opened front}}"
        opened_note_type.save

        note = AnkiRecord::Note.new note_type: opened_note_type, deck: default_deck
        note.opened_front = "Hello"
        note.opened_back = "World"
        note.save
        @note_type_id = opened_note_type.id
        @note_id = note.id
      end
    end

    it "returns a note type" do
      expect(collection_instantiated_from_open.find_note_type_by(name: note_type_name)).to be_a AnkiRecord::NoteType
    end

    it "returns a note type with the same id as the existing note type from the opened package" do
      expect(collection_instantiated_from_open.find_note_type_by(name: note_type_name).id).to eq @note_type_id
    end
    # rubocop:enable RSpec/InstanceVariable
  end
end
