# frozen_string_literal: true

require_relative "../support/note_type_spec_helpers"

RSpec.describe AnkiRecord::NoteType, "#allowed_card_template_answer_format_field_names" do
  subject(:basic_note_type_from_existing) { described_class.new(collection: collection_argument, args: basic_model_hash) }

  include_context "note type helpers"

  let(:name_argument) { "test note type" }
  let(:collection_argument) do
    anki_package = AnkiRecord::AnkiPackage.new(name: "package_to_setup_collection")
    AnkiRecord::Collection.new(anki_package: anki_package)
  end

  context "when it is a a non-cloze note type" do
    it "returns an array with the string names of the note type's fields' names and 'FrontSide'" do
      expect(basic_note_type_from_existing.allowed_card_template_answer_format_field_names).to eq %w[Front Back FrontSide]
    end
  end

  context "when it is a cloze note type" do
    it "returns an array with the string names of the note type's fields' names, 'FrontSide', and the note type's fields' names prepended with 'cloze:'" do
      basic_note_type_from_existing.cloze = true
      expect(basic_note_type_from_existing.allowed_card_template_answer_format_field_names).to eq ["Front", "Back", "cloze:Front", "cloze:Back", "FrontSide"]
    end
  end
end
