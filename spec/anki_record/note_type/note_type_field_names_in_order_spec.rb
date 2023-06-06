# frozen_string_literal: true

require_relative "../support/clean_slate_anki_package"
require_relative "../support/note_type_hashes"

RSpec.describe AnkiRecord::NoteType, "#field_names_in_order" do
  include_context "when the JSON of a note type from the col record is a Ruby hash"
  include_context "when the anki package is a clean slate"

  context "when it is the default Basic note type" do
    subject(:basic_note_type_from_hash) { described_class.new(anki21_database:, args: basic_model_hash) }

    it "returns an array ['Front', 'Back'] which are the field names in the correct order" do
      expect(basic_note_type_from_hash.field_names_in_order).to eq %w[Front Back]
    end
  end

  context "when it is a note type with four custom fields" do
    subject(:note_type) { described_class.new anki21_database:, name: }

    let(:name) { "test note type" }

    it "returns an array with the field names in the correct order" do
      4.times { |i| AnkiRecord::NoteField.new note_type:, name: "Field #{i + 1}" }
      expect(note_type.field_names_in_order).to eq ["Field 1", "Field 2", "Field 3", "Field 4"]
    end
  end
end
