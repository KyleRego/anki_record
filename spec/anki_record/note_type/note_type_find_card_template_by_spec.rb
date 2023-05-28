# frozen_string_literal: true

require_relative "../support/note_type_spec_helpers"

RSpec.describe AnkiRecord::NoteType, "#find_card_template_by" do
  subject(:basic_note_type_from_existing) { described_class.new(collection: collection_argument, args: basic_model_hash) }

  include_context "note type helpers"

  # TODO: Extract to shared context or DRY this as it's repeated in many note_type spec files.
  let(:name_argument) { "test note type" }
  let(:collection_argument) do
    anki_package = AnkiRecord::AnkiPackage.new(name: "package_to_setup_collection")
    anki_package.anki21_database.collection
  end

  context "when passed a name argument where the note type does not have a card template with that name" do
    it "returns nil" do
      expect(basic_note_type_from_existing.find_card_template_by(name: "does not exist")).to be_nil
    end
  end

  context "when passed a name argument where the note type has a card template with that name" do
    it "returns a card template object" do
      expect(basic_note_type_from_existing.find_card_template_by(name: "Card 1").instance_of?(AnkiRecord::CardTemplate)).to be true
    end

    it "returns a card template object with name equal to the name argument" do
      expect(basic_note_type_from_existing.find_card_template_by(name: "Card 1").name).to eq "Card 1"
    end
  end
end
