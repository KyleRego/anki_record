# frozen_string_literal: true

require "./spec/anki_record/support/clean_slate_anki_package"
require "./spec/anki_record/support/deck_hash"

RSpec.describe AnkiRecord::Deck, "#new" do
  include_context "when the anki package is a clean slate"

  context "when passed collection and name arguments" do
    subject(:deck) { described_class.new collection:, name: "test deck" }

    # rubocop:disable RSpec/ExampleLength
    it "instantiates a deck with that name" do
      expect(deck).to be_a described_class
      expect(deck.collection).to eq collection
      expect(deck.collection.decks).to include deck
      expect(deck.description).to eq ""
      expect(deck.id).to be_a Integer
      expect(deck.id).to be_a Integer
      expect(deck.deck_options_group).to be_a AnkiRecord::DeckOptionsGroup
      expect(deck.deck_options_group.id).to eq 1
      expect(collection.decks_json.keys).not_to include deck.id.to_s
    end
  end
  # rubocop:enable RSpec/ExampleLength

  it "throws an ArgumentError when passed collection, name, and args arguments" do
    expect { described_class.new(collection:, name: "test", args: {}) }.to raise_error ArgumentError
  end

  context "when passed collection and args arguments (and args is the Default deck hash)" do
    subject(:default_deck_from_hash) { described_class.new(collection:, args: default_deck_hash) }

    include_context "when the JSON of a deck from the col record is a Ruby hash"

    # rubocop:disable RSpec/ExampleLength
    it "instantiates a deck from the raw data" do
      expect(default_deck_from_hash.collection).to eq collection
      expect(default_deck_from_hash.collection.decks).to include default_deck_from_hash
      expect(default_deck_from_hash.id).to eq 1
      expect(default_deck_from_hash.last_modified_timestamp).to eq 0
      expect(default_deck_from_hash.name).to eq "Default"
      expect(default_deck_from_hash.description).to eq ""
      expect(default_deck_from_hash.deck_options_group).to be_a AnkiRecord::DeckOptionsGroup
      expect(default_deck_from_hash.deck_options_group.id).to eq 1
      expect(collection.decks_json.keys).to include default_deck_from_hash.id.to_s
    end
    # rubocop:enable RSpec/ExampleLength
  end
end
