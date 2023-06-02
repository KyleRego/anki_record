# frozen_string_literal: true

require_relative "../support/clean_slate_anki_package"
require_relative "../support/note_type_hashes"

RSpec.describe AnkiRecord::NoteType, "#deck=" do
  subject(:basic_note_type_from_hash) { described_class.new(collection:, args: basic_model_hash) }

  include_context "when the JSON of a note type from the col record is a Ruby hash"
  include_context "when the anki package is a clean slate"

  let(:default_deck) { basic_note_type_from_hash.collection.find_deck_by name: "Default" }

  context "when used to set the deck to be a deck object" do
    it "sets the deck object to be the deck" do
      basic_note_type_from_hash.deck = default_deck
      expect(basic_note_type_from_hash.deck).to eq default_deck
    end
  end

  context "when used to set the deck to a non-deck object" do
    it "raises an ArgumentError" do
      expect { basic_note_type_from_hash.deck = "Macaroni" }.to raise_error ArgumentError
    end
  end
end
