# frozen_string_literal: true

require "./spec/anki_record/support/clean_slate_anki_package"

RSpec.describe AnkiRecord::Deck, "#save" do
  include_context "when the anki package is a clean slate"

  context "when the deck does not exist in the collection.anki21 database" do
    subject(:test_deck) { described_class.new(anki21_database:, name: test_deck_name) }

    let(:test_deck_name) { "test deck for save" }
    let(:decks_json_from_collection) { anki21_database.decks_json }
    let(:deck_json_from_decks_json_from_collection) { decks_json_from_collection[test_deck.id.to_s] }

    before { test_deck.save }

    # rubocop:disable RSpec/ExampleLength
    it "saves the deck as the hash value for the deck's id key in the decks column's JSON object in the collection.anki21 database" do
      expect(decks_json_from_collection.keys).to include test_deck.id.to_s
      expect(deck_json_from_decks_json_from_collection).to be_a Hash
      %w[id mod name usn lrnToday revToday newToday timeToday collapsed browserCollapsed desc dyn conf extendNew extendRev].each do |key|
        expect(deck_json_from_decks_json_from_collection.keys).to include key
      end
      expect(deck_json_from_decks_json_from_collection["id"]).to eq test_deck.id
      expect(deck_json_from_decks_json_from_collection["mod"]).to eq test_deck.last_modified_timestamp
      expect(deck_json_from_decks_json_from_collection["name"]).to eq test_deck.name
      expect(deck_json_from_decks_json_from_collection["usn"]).to eq(-1)
      expect(deck_json_from_decks_json_from_collection["lrnToday"]).to eq [0, 0]
      expect(deck_json_from_decks_json_from_collection["revToday"]).to eq [0, 0]
      expect(deck_json_from_decks_json_from_collection["newToday"]).to eq [0, 0]
      expect(deck_json_from_decks_json_from_collection["timeToday"]).to eq [0, 0]
      expect(deck_json_from_decks_json_from_collection["collapsed"]).to be false
      expect(deck_json_from_decks_json_from_collection["browserCollapsed"]).to be false
      expect(deck_json_from_decks_json_from_collection["desc"]).to eq test_deck.description
      expect(deck_json_from_decks_json_from_collection["dyn"]).to eq 0
      expect(deck_json_from_decks_json_from_collection["conf"]).to eq test_deck.deck_options_group.id
      expect(deck_json_from_decks_json_from_collection["extendNew"]).to eq 0
      expect(deck_json_from_decks_json_from_collection["extendRev"]).to eq 0
    end
    # rubocop:enable RSpec/ExampleLength
  end

  # TODO: Check that the deck is updated in the database when it is saved with unpersisted changes.
  context "when the deck does exist in the collection.anki21 database"
end
