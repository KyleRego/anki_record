# frozen_string_literal: true

require_relative "../support/note_type_spec_helpers"

RSpec.describe AnkiRecord::NoteType, "#snake_case_sort_field_name" do
  subject(:basic_note_type_from_existing) { described_class.new(collection: collection_argument, args: basic_model_hash) }

  include_context "note type helpers"

  let(:note_type) { described_class.new collection: collection_argument, name: name_argument }
  let(:name_argument) { "test note type" }
  let(:collection_argument) do
    AnkiRecord::AnkiPackage.new(name: "package_to_setup_collection").collection
  end

  context "when it is the default Basic note type" do
    it "returns the name of the field used to sort, 'Front', but in snake_case: front" do
      expect(basic_note_type_from_existing.snake_case_sort_field_name).to eq "front"
    end
  end

  context "when it is a note type with a note field called 'Crazy Note Field Name' which is the sort field" do
    it "returns 'crazy_note_field_name'" do
      AnkiRecord::NoteField.new note_type: note_type, name: "Crazy Note Field Name"
      expect(note_type.snake_case_sort_field_name).to eq "crazy_note_field_name"
    end
  end
end
