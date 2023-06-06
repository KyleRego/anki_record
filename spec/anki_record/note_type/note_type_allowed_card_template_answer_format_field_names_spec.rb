# frozen_string_literal: true

require_relative "../support/clean_slate_anki_package"
require_relative "../support/note_type_hashes"

RSpec.describe AnkiRecord::NoteType, "#allowed_card_template_answer_format_field_names" do
  subject(:basic_note_type_from_hash) { described_class.new(anki21_database:, args: basic_model_hash) }

  include_context "when the JSON of a note type from the col record is a Ruby hash"
  include_context "when the anki package is a clean slate"

  context "when it is a a non-cloze note type" do
    it "returns an array with the string names of the note type's fields' names and 'FrontSide'" do
      expect(basic_note_type_from_hash.allowed_card_template_answer_format_field_names).to eq %w[Front Back FrontSide]
    end
  end

  context "when it is a cloze note type" do
    it "returns an array with the string names of the note type's fields' names, 'FrontSide', and the note type's fields' names prepended with 'cloze:'" do
      basic_note_type_from_hash.cloze = true
      expect(basic_note_type_from_hash.allowed_card_template_answer_format_field_names).to eq ["Front", "Back", "cloze:Front", "cloze:Back", "FrontSide"]
    end
  end
end
