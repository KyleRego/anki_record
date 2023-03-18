# frozen_string_literal: true

RSpec.describe AnkiRecord::Deck do
  subject(:deck) { AnkiRecord::Deck.new(collection: collection_argument, name: deck_name_argument) }
  let(:deck_name_argument) { "test deck name" }

  after { cleanup_test_files(directory: ".") }

  let(:collection_argument) do
    anki_package = AnkiRecord::AnkiPackage.new(name: "package_to_setup_collection")
    AnkiRecord::Collection.new(anki_package: anki_package)
  end

  describe "::new" do
    context "when passed collection and name arguments" do
      it "should instantiate a new Deck object" do
        expect(deck.instance_of?(AnkiRecord::Deck)).to eq true
      end
      it "should instantiate a deck with collection attribute which is the collection argument" do
        expect(deck.collection).to eq collection_argument
      end
      it "should instantiate a deck which is added to the decks of the collection argument's decks attribute" do
        expect(deck.collection.decks).to include deck
      end
      it "should instantiate a deck with an empty string description" do
        expect(deck.description).to eq ""
      end
      it "should instantiate a deck with an integer id attribute" do
        expect(deck.id.instance_of?(Integer)).to eq true
      end
      it "should instantiate a deck with an integer last_modified_time attribute" do
        expect(deck.id.instance_of?(Integer)).to eq true
      end
      it "should instantiate a deck with a deck_options_group_id being 1" do
        expect(deck.deck_options_group_id).to eq 1
      end
    end
    context "when passed a collection argument, and name and args arguments" do
      it "should throw an ArgumentError" do
        expect { AnkiRecord::Deck.new(collection: collection_argument, name: "test", args: {}) }.to raise_error ArgumentError
      end
    end
  end

  subject(:deck_from_existing) { AnkiRecord::Deck.new(collection: collection_argument, args: deck_hash) }

  describe "::new" do
    context "when passed collection and args arguments" do
      context "and the deck JSON object (args) is the default deck from a fresh Anki profile" do
        let(:deck_hash) do
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
        it "should instantiate a deck with collection attribute equal to the collection argument" do
          expect(deck_from_existing.collection).to eq collection_argument
        end
        it "should instantiate a deck which is added to the decks of the collection argument's decks attribute" do
          expect(deck_from_existing.collection.decks).to include deck
        end
        it "should instantiate a deck with the id from the deck JSON" do
          expect(deck_from_existing.id).to eq 1
        end
        it "should instantiate a deck with the last modified time from the deck JSON" do
          expect(deck_from_existing.last_modified_time).to eq 0
        end
        it "should instantiate a deck with the name Default" do
          expect(deck_from_existing.name).to eq "Default"
        end
        it "should instantiate a deck with the description from the deck JSON" do
          expect(deck_from_existing.description).to eq ""
        end
        it "should instantiate a deck with the deck options group id from the deck JSON (the conf)" do
          expect(deck_from_existing.deck_options_group_id).to eq 1
        end
      end
    end
  end

  describe "#save" do
    let(:crazy_deck_name) { "crazy deck" }
    subject(:crazy_deck) do
      AnkiRecord::Deck.new name: crazy_deck_name, collection: collection_argument
    end
    let(:col_decks_hash) { collection_argument.decks_json }
    let(:crazy_deck_hash) { col_decks_hash[crazy_deck.id.to_s] }

    before { crazy_deck.save }
    it "should save the deck object's id as a key in the decks column's JSON object in the collection.anki21 database" do
      expect(col_decks_hash.keys).to include crazy_deck.id.to_s
    end
    it "should save the deck object as a hash, as the value of the deck object's id key, in the decks hash" do
      expect(crazy_deck_hash).to be_a Hash
    end
    it "should save the deck object as a hash with the following keys:
      'id', 'mod', 'name', 'usn', 'lrnToday', 'revToday',
      'newToday', 'timeToday', 'collapsed', 'browserCollapsed',
      'desc', 'dyn', 'conf', 'extendNew', 'extendRev'" do
      %w[id mod name usn lrnToday revToday newToday timeToday collapsed browserCollapsed desc dyn conf extendNew extendRev].each do |key|
        expect(crazy_deck_hash.keys).to include key
      end
    end
    context "should save the deck object as a hash" do
      it "with the deck object's id attribute as the value for the id key in the deck hash" do
        expect(crazy_deck_hash["id"]).to eq crazy_deck.id
      end
      it "with the deck object's last_modified_time attribute as the value for the mod key in the deck hash" do
        expect(crazy_deck_hash["mod"]).to eq crazy_deck.last_modified_time
      end
      it "with the deck object's name attribute as the value for the name key in the deck hash" do
        expect(crazy_deck_hash["name"]).to eq crazy_deck.name
      end
      it "with -1 for the value of the usn key in the deck hash" do
        expect(crazy_deck_hash["usn"]).to eq(-1)
      end
      it "with [0, 0] for the value of the lrnToday key in the deck hash" do
        expect(crazy_deck_hash["lrnToday"]).to eq [0, 0]
      end
      it "with [0, 0] for the value of the revToday key in the deck hash" do
        expect(crazy_deck_hash["revToday"]).to eq [0, 0]
      end
      it "with [0, 0] for the value of the newToday key in the deck hash" do
        expect(crazy_deck_hash["newToday"]).to eq [0, 0]
      end
      it "with [0, 0] for the value of the timeToday key in the deck hash" do
        expect(crazy_deck_hash["timeToday"]).to eq [0, 0]
      end
      it "with false for the value of the collapsed key in the deck hash" do
        expect(crazy_deck_hash["collapsed"]).to eq false
      end
      it "with false for the value of the browserCollapsed key in the deck hash" do
        expect(crazy_deck_hash["browserCollapsed"]).to eq false
      end
      it "with the deck object's description attribute as the value for the desc key in the deck hash" do
        expect(crazy_deck_hash["desc"]).to eq crazy_deck.description
      end
      it "with 0 for the value of the dyn key in the deck hash" do
        expect(crazy_deck_hash["dyn"]).to eq 0
      end
      it "with the deck object's deck_options_group_id attribute as the value for the conf key in the deck hash" do
        expect(crazy_deck_hash["conf"]).to eq crazy_deck.deck_options_group_id
      end
      it "with 0 for the value of the extendNew key in the deck hash" do
        expect(crazy_deck_hash["extendNew"]).to eq 0
      end
      it "with 0 for the value of the extendRev key in the deck hash" do
        expect(crazy_deck_hash["extendRev"]).to eq 0
      end
    end
  end
end
