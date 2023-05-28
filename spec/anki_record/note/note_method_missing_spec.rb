# frozen_string_literal: true

RSpec.describe AnkiRecord::Note, "#method_missing" do
  subject(:note) do
    anki_package = AnkiRecord::AnkiPackage.new(name: "package_to_test_notes")
    collection = anki_package.anki21_database.collection
    basic_note_type = collection.find_note_type_by name: "Basic"
    default_deck = collection.find_deck_by name: "Default"
    described_class.new deck: default_deck, note_type: basic_note_type
  end

  after { cleanup_test_files(directory: ".") }

  context "when the missing method ends with '='" do
    context "when the method does not correspond to one of the snake_case note type field names" do
      it "throws an error" do
        expect { note.made_up_field = "Made up" }.to raise_error NoMethodError
      end
    end

    context "when the method corresponds to one of the snake_case note type field names" do
      it "sets that field" do
        note.front = "Content of the note Front field"
        expect(note.front).to eq "Content of the note Front field"
      end
    end
  end

  context "when the missing method does not end with '=" do
    context "when the method does not correspond to one of the snake_case note type field names" do
      it "throws an error" do
        expect { note.what_this_method }.to raise_error NoMethodError
      end
    end

    context "when the method corresponds to one of the snake_card note type field names"
  end
end
