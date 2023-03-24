# frozen_string_literal: true

RSpec.describe AnkiRecord::Deck do
  after { cleanup_test_files(directory: ".") }

  describe "::new when passed collection and name arguments" do
    before(:all) do
      @collection = AnkiRecord::AnkiPackage.new(name: "decks_spec_package_1").collection
      @deck = AnkiRecord::Deck.new collection: @collection, name: "test deck"
    end
    it "should instantiate a new Deck object" do
      expect(@deck).to be_a AnkiRecord::Deck
    end
    it "should instantiate a deck with collection attribute which is the collection argument" do
      expect(@deck.collection).to eq @collection
    end
    it "should instantiate a deck which is added to the decks of the collection argument's decks attribute" do
      expect(@deck.collection.decks).to include @deck
    end
    it "should instantiate a deck with an empty string description" do
      expect(@deck.description).to eq ""
    end
    it "should instantiate a deck with an integer id attribute" do
      expect(@deck.id).to be_a Integer
    end
    it "should instantiate a deck with an integer last_modified_timestamp attribute" do
      expect(@deck.id).to be_a Integer
    end
    it "should instantiate a deck with deck_options_group returning a deck options group object" do
      expect(@deck.deck_options_group).to be_a AnkiRecord::DeckOptionsGroup
    end
    it "should instantiate a deck with deck_options_group returning a deck options group object with an id equal to 1" do
      expect(@deck.deck_options_group.id).to eq 1
    end
  end

  describe "::new when passed collection, name, and args arguments" do
    before { @collection = AnkiRecord::AnkiPackage.new(name: "decks_spec_package").collection }
    it "should throw an ArgumentError" do
      expect { AnkiRecord::Deck.new(collection: @collection, name: "test", args: {}) }.to raise_error ArgumentError
    end
  end

  # rubocop:disable Metrics/MethodLength
  ##
  # Returns the Ruby hash for the Default deck args
  def default_deck_hash
    { "id" => 1,
      "mod" => 0,
      "name" => "Default",
      "usn" => 0,
      "lrnToday" => [0, 0],
      "revToday" => [0, 0],
      "newToday" => [0, 0],
      "timeToday" => [0, 0],
      "collapsed" => true,
      "browserCollapsed" => true,
      "desc" => "",
      "dyn" => 0,
      "conf" => 1,
      "extendNew" => 0,
      "extendRev" => 0 }
  end
  # rubocop:enable Metrics/MethodLength

  describe "::new when passed collection and args arguments (and args is the Default deck hash)" do
    before(:all) do
      @collection = AnkiRecord::AnkiPackage.new(name: "decks_spec_package_2").collection
      @default_deck_from_existing = AnkiRecord::Deck.new(collection: @collection, args: default_deck_hash)
    end
    it "should instantiate a deck with collection attribute equal to the collection argument" do
      expect(@default_deck_from_existing.collection).to eq @collection
    end
    it "should instantiate a deck which is added to the decks of the collection argument's decks attribute" do
      expect(@default_deck_from_existing.collection.decks).to include @default_deck_from_existing
    end
    it "should instantiate a deck with the id from the deck JSON" do
      expect(@default_deck_from_existing.id).to eq 1
    end
    it "should instantiate a deck with the last modified time from the deck JSON" do
      expect(@default_deck_from_existing.last_modified_timestamp).to eq 0
    end
    it "should instantiate a deck with the name Default" do
      expect(@default_deck_from_existing.name).to eq "Default"
    end
    it "should instantiate a deck with the description from the deck JSON" do
      expect(@default_deck_from_existing.description).to eq ""
    end
    it "should instantiate a deck with deck_options_group returning a deck options group object" do
      expect(@default_deck_from_existing.deck_options_group).to be_a AnkiRecord::DeckOptionsGroup
    end
    it "should instantiate a deck with deck_options_group returnign a deck options group object with id equal to id the value from the deck JSON (the conf)" do
      expect(@default_deck_from_existing.deck_options_group.id).to eq 1
    end
  end

  describe "#save called on a new deck that does not exist yet in the collection.anki21 database" do
    before(:all) do
      @collection = AnkiRecord::AnkiPackage.new(name: "decks_spec_package_3").collection
      @crazy_deck_name = "crazy deck"
      @crazy_deck = AnkiRecord::Deck.new name: @crazy_deck_name, collection: @collection
      @col_decks_hash = @collection.decks_json
      @crazy_deck_hash = @col_decks_hash[@crazy_deck.id.to_s]
    end
    it "should save the deck object's id as a key in the decks column's JSON object in the collection.anki21 database" do
      expect(@col_decks_hash.keys).to include @crazy_deck.id.to_s
    end
    it "should save the deck object as a hash, as the value of the deck object's id key, in the decks hash" do
      expect(@crazy_deck_hash).to be_a Hash
    end
    it "should save the deck object as a hash with the following keys:
      'id', 'mod', 'name', 'usn', 'lrnToday', 'revToday',
      'newToday', 'timeToday', 'collapsed', 'browserCollapsed',
      'desc', 'dyn', 'conf', 'extendNew', 'extendRev'" do
      %w[id mod name usn lrnToday revToday newToday timeToday collapsed browserCollapsed desc dyn conf extendNew extendRev].each do |key|
        expect(@crazy_deck_hash.keys).to include key
      end
    end
    context "should save the deck object as a hash" do
      it "with the deck object's id attribute as the value for the id key in the deck hash" do
        expect(@crazy_deck_hash["id"]).to eq @crazy_deck.id
      end
      it "with the deck object's last_modified_timestamp attribute as the value for the mod key in the deck hash" do
        expect(@crazy_deck_hash["mod"]).to eq @crazy_deck.last_modified_timestamp
      end
      it "with the deck object's name attribute as the value for the name key in the deck hash" do
        expect(@crazy_deck_hash["name"]).to eq @crazy_deck.name
      end
      it "with -1 for the value of the usn key in the deck hash" do
        expect(@crazy_deck_hash["usn"]).to eq(-1)
      end
      it "with [0, 0] for the value of the lrnToday key in the deck hash" do
        expect(@crazy_deck_hash["lrnToday"]).to eq [0, 0]
      end
      it "with [0, 0] for the value of the revToday key in the deck hash" do
        expect(@crazy_deck_hash["revToday"]).to eq [0, 0]
      end
      it "with [0, 0] for the value of the newToday key in the deck hash" do
        expect(@crazy_deck_hash["newToday"]).to eq [0, 0]
      end
      it "with [0, 0] for the value of the timeToday key in the deck hash" do
        expect(@crazy_deck_hash["timeToday"]).to eq [0, 0]
      end
      it "with false for the value of the collapsed key in the deck hash" do
        expect(@crazy_deck_hash["collapsed"]).to eq false
      end
      it "with false for the value of the browserCollapsed key in the deck hash" do
        expect(@crazy_deck_hash["browserCollapsed"]).to eq false
      end
      it "with the deck object's description attribute as the value for the desc key in the deck hash" do
        expect(@crazy_deck_hash["desc"]).to eq @crazy_deck.description
      end
      it "with 0 for the value of the dyn key in the deck hash" do
        expect(@crazy_deck_hash["dyn"]).to eq 0
      end
      it "with the deck object's deck options group's id attribute as the value for the conf key in the deck hash" do
        expect(@crazy_deck_hash["conf"]).to eq @crazy_deck.deck_options_group.id
      end
      it "with 0 for the value of the extendNew key in the deck hash" do
        expect(@crazy_deck_hash["extendNew"]).to eq 0
      end
      it "with 0 for the value of the extendRev key in the deck hash" do
        expect(@crazy_deck_hash["extendRev"]).to eq 0
      end
    end
  end

  describe "#save called on a new deck that already exists in the collection.anki21 database"
end
