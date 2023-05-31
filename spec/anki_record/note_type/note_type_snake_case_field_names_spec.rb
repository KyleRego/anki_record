# frozen_string_literal: true

require_relative "../support/clean_slate_anki_package"
require_relative "../support/note_type_hashes"

RSpec.describe AnkiRecord::NoteType, "#snake_case_field_names" do
  include_context "when the JSON of a note type from the col record is a Ruby hash"
  include_context "when the anki package is a clean slate"

  context "when it is the default Basic note type" do
    let(:basic_note_type_from_hash) { described_class.new(collection: collection, args: basic_model_hash) }

    it "returns an array including the values 'front' and 'back'" do
      expect(basic_note_type_from_hash.snake_case_field_names).to eq %w[front back]
    end
  end

  context "when it is a custom note type" do
    let(:note_type) { described_class.new collection: collection, name: name }
    let(:name) { "test note type" }

    it "returns an array with 'crazy_note_field_name' if the note field is 'Crazy Note Field Name'" do
      AnkiRecord::NoteField.new note_type: note_type, name: "Crazy Note Field Name"
      expect(note_type.snake_case_field_names).to eq ["crazy_note_field_name"]
    end

    it "returns an array with 'crazy_note_field_name' if the note field is 'Double Spaces'" do
      AnkiRecord::NoteField.new note_type: note_type, name: "Double  Spaces"
      expect(note_type.snake_case_field_names).to eq ["double__spaces"]
    end
  end
end
