# frozen_string_literal: true

require_relative "../support/note_type_spec_helpers"

RSpec.describe AnkiRecord::NoteType, "#snake_case_field_names" do
  subject(:basic_note_type_from_existing) { described_class.new(collection: collection_argument, args: basic_model_hash) }

  include_context "note type helpers"

  let(:note_type) { described_class.new collection: collection_argument, name: name_argument }
  let(:name_argument) { "test note type" }
  let(:collection_argument) do
    AnkiRecord::AnkiPackage.new(name: "package_to_setup_collection").anki21_database.collection
  end

  context "when it is the default Basic note type" do
    it "returns an array including the values 'front' and 'back'" do
      expect(basic_note_type_from_existing.snake_case_field_names).to eq %w[front back]
    end
  end

  context "when it is a note type with a note field called 'Crazy Note Field Name'" do
    it "returns an array including the value 'crazy_note_field_name'" do
      AnkiRecord::NoteField.new note_type: note_type, name: "Crazy Note Field Name"
      expect(note_type.snake_case_field_names).to eq ["crazy_note_field_name"]
    end
  end

  context "when it is a note type with a note field called 'Double Spaces'" do
    it "returns an array including the value 'crazy_note_field_name'" do
      AnkiRecord::NoteField.new note_type: note_type, name: "Double  Spaces"
      expect(note_type.snake_case_field_names).to eq ["double__spaces"]
    end
  end
end
