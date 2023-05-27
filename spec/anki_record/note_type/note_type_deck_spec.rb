# frozen_string_literal: true

require_relative "../support/note_type_spec_helpers"

RSpec.describe AnkiRecord::NoteType, "#deck=" do
  subject(:basic_note_type_from_existing) { described_class.new(collection: collection_argument, args: basic_model_hash) }

  include_context "note type helpers"

  let(:name_argument) { "test note type" }
  let(:collection_argument) do
    AnkiRecord::AnkiPackage.new(name: "package_to_setup_collection").collection
  end

  let(:default_deck) { basic_note_type_from_existing.collection.find_deck_by name: "Default" }

  context "when used to set the deck to be a deck object" do
    it "sets the deck object to be the deck" do
      basic_note_type_from_existing.deck = default_deck
      expect(basic_note_type_from_existing.deck).to eq default_deck
    end
  end

  context "when used to set the deck to a non-deck object" do
    it "raises an ArgumentError" do
      expect { basic_note_type_from_existing.deck = "Meg" }.to raise_error ArgumentError
    end
  end
end
