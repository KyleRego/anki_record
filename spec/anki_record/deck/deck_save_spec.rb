# frozen_string_literal: true

# TODO: Specs can be refactored for performance.
RSpec.describe AnkiRecord::Deck, "#save" do
  after { cleanup_test_files(directory: ".") }

  describe "when the deck does not exist in the collection.anki21 database" do
    subject(:test_deck) { described_class.new name: test_deck_name, collection: collection }

    let(:collection) { AnkiRecord::AnkiPackage.new(name: "decks_spec_package_3").anki21_database.collection }
    let(:test_deck_name) { "test deck for save" }
    let(:decks_json_from_collection) { collection.decks_json }
    let(:test_deck_database_json) { decks_json_from_collection[test_deck.id.to_s] }

    before { test_deck.save }

    it "saves the deck object's id as a key in the decks column's JSON object in the collection.anki21 database" do
      expect(decks_json_from_collection.keys).to include test_deck.id.to_s
    end

    it "saves the deck object as a hash, as the value of the deck object's id key, in the decks hash" do
      expect(test_deck_database_json).to be_a Hash
    end

    it "saves the deck object as a hash with the following keys: 'id', 'mod', 'name', 'usn', 'lrnToday', 'revToday', 'newToday', 'timeToday', 'collapsed', 'browserCollapsed', 'desc', 'dyn', 'conf', 'extendNew', 'extendRev'" do
      %w[id mod name usn lrnToday revToday newToday timeToday collapsed browserCollapsed desc dyn conf extendNew extendRev].each do |key|
        expect(test_deck_database_json.keys).to include key
      end
    end

    it "saves the deck object as a hash with the deck object's id attribute as the value for the id key in the deck hash" do
      expect(test_deck_database_json["id"]).to eq test_deck.id
    end

    it "saves the deck object as a hash with the deck object's last_modified_timestamp attribute as the value for the mod key in the deck hash" do
      expect(test_deck_database_json["mod"]).to eq test_deck.last_modified_timestamp
    end

    it "saves the deck object as a hash with the deck object's name attribute as the value for the name key in the deck hash" do
      expect(test_deck_database_json["name"]).to eq test_deck.name
    end

    it "saves the deck object as a hash with -1 for the value of the usn key in the deck hash" do
      expect(test_deck_database_json["usn"]).to eq(-1)
    end

    it "saves the deck object as a hash with [0, 0] for the value of the lrnToday key in the deck hash" do
      expect(test_deck_database_json["lrnToday"]).to eq [0, 0]
    end

    it "saves the deck object as a hash with [0, 0] for the value of the revToday key in the deck hash" do
      expect(test_deck_database_json["revToday"]).to eq [0, 0]
    end

    it "saves the deck object as a hash with [0, 0] for the value of the newToday key in the deck hash" do
      expect(test_deck_database_json["newToday"]).to eq [0, 0]
    end

    it "saves the deck object as a hash with [0, 0] for the value of the timeToday key in the deck hash" do
      expect(test_deck_database_json["timeToday"]).to eq [0, 0]
    end

    it "saves the deck object as a hash with false for the value of the collapsed key in the deck hash" do
      expect(test_deck_database_json["collapsed"]).to be false
    end

    it "saves the deck object as a hash with false for the value of the browserCollapsed key in the deck hash" do
      expect(test_deck_database_json["browserCollapsed"]).to be false
    end

    it "saves the deck object as a hash with the deck object's description attribute as the value for the desc key in the deck hash" do
      expect(test_deck_database_json["desc"]).to eq test_deck.description
    end

    it "saves the deck object as a hash with 0 for the value of the dyn key in the deck hash" do
      expect(test_deck_database_json["dyn"]).to eq 0
    end

    it "saves the deck object as a hash with the deck object's deck options group's id attribute as the value for the conf key in the deck hash" do
      expect(test_deck_database_json["conf"]).to eq test_deck.deck_options_group.id
    end

    it "saves the deck object as a hash with 0 for the value of the extendNew key in the deck hash" do
      expect(test_deck_database_json["extendNew"]).to eq 0
    end

    it "saves the deck object as a hashwith 0 for the value of the extendRev key in the deck hash" do
      expect(test_deck_database_json["extendRev"]).to eq 0
    end
  end
end
