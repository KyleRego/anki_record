# frozen_string_literal: true

require_relative "../support/note_type_spec_helpers"

RSpec.describe AnkiRecord::NoteType, "#field_names_in_order" do
  include_context "note type helpers"

  let(:name_argument) { "test note type" }
  let(:collection_argument) do
    anki_package = AnkiRecord::AnkiPackage.new(name: "package_to_setup_collection")
    AnkiRecord::Collection.new(anki_package: anki_package)
  end

  context "when it is the default Basic note type" do
    subject(:basic_note_type_from_existing) { described_class.new(collection: collection_argument, args: basic_model_hash) }

    it "returns an array ['Front', 'Back'] which are the field names in the correct order" do
      expect(basic_note_type_from_existing.field_names_in_order).to eq %w[Front Back]
    end
  end

  context "when it is a note type with four custom fields" do
    subject(:note_type) { described_class.new collection: collection_argument, name: name_argument }

    it "returns an array with the field names in the correct order" do
      4.times { |i| AnkiRecord::NoteField.new note_type: note_type, name: "Field #{i + 1}" }
      expect(note_type.field_names_in_order).to eq ["Field 1", "Field 2", "Field 3", "Field 4"]
    end
  end
end
