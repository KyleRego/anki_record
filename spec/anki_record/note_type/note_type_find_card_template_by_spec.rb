# frozen_string_literal: true

require_relative "../support/clean_slate_anki_package"
require_relative "../support/note_type_hashes"

RSpec.describe AnkiRecord::NoteType, "#find_card_template_by" do
  subject(:basic_note_type_from_hash) { described_class.new(collection:, args: basic_model_hash) }

  include_context "when the JSON of a note type from the col record is a Ruby hash"
  include_context "when the anki package is a clean slate"

  context "when passed a name argument where the note type does not have a card template with that name" do
    it "returns nil" do
      expect(basic_note_type_from_hash.find_card_template_by(name: "does not exist")).to be_nil
    end
  end

  context "when passed a name argument where the note type has a card template with that name" do
    it "returns a card template object" do
      expect(basic_note_type_from_hash.find_card_template_by(name: "Card 1").instance_of?(AnkiRecord::CardTemplate)).to be true
    end

    it "returns a card template object with name equal to the name argument" do
      expect(basic_note_type_from_hash.find_card_template_by(name: "Card 1").name).to eq "Card 1"
    end
  end
end
