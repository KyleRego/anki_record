# frozen_string_literal: true

require_relative "../support/clean_slate_anki_package"
require_relative "../support/note_type_hashes"

RSpec.describe AnkiRecord::NoteType, "#snake_case_sort_field_name" do
  include_context "when the JSON of a note type from the col record is a Ruby hash"
  include_context "when the anki package is a clean slate"

  context "when it is the default Basic note type" do
    let(:basic_note_type_from_hash) { described_class.new(anki21_database:, args: basic_model_hash) }

    it "returns the name of the field used to sort, 'Front', but in snake_case: front" do
      expect(basic_note_type_from_hash.snake_case_sort_field_name).to eq "front"
    end
  end

  context "when it is a note type with a note field called 'Crazy Note Field Name' which is the sort field" do
    let(:note_type) { described_class.new anki21_database:, name: }
    let(:name) { "test note type" }

    it "returns 'crazy_note_field_name'" do
      AnkiRecord::NoteField.new note_type:, name: "Crazy Note Field Name"
      expect(note_type.snake_case_sort_field_name).to eq "crazy_note_field_name"
    end
  end
end
