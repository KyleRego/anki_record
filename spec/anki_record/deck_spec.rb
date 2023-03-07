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
      it "should instantiate a deck with a deck_options_group_id being nil" do
        expect(deck.deck_options_group_id).to eq nil
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
end
