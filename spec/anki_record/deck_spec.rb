# frozen_string_literal: true

RSpec.describe AnkiRecord::Deck do
  subject(:deck) { AnkiRecord::Deck.new(collection: collection_argument, name: deck_name_argument) }
  let(:deck_name_argument) { "test deck name" }

  after { cleanup_test_files(directory: ".") }

  let(:collection_argument) do
    anki_package = AnkiRecord::AnkiPackage.new(name: "package_to_setup_collection")
    AnkiRecord::Collection.new(anki_package: anki_package)
  end

  describe "::new used with a name argument" do
    it "instantiates a new Deck object" do
      expect(deck.instance_of?(AnkiRecord::Deck)).to eq true
    end
    context "with a name argument and an args argument" do
      it "throw an ArgumentError" do
        expect { AnkiRecord::Deck.new(collection: collection_argument, name: "test", args: {}) }.to raise_error ArgumentError
      end
    end
  end

  subject(:deck_from_existing) { AnkiRecord::Deck.new(collection: collection_argument, args: deck_hash) }

  describe "::new passed an args hash" do
    context "when the deck JSON object is the default deck from a fresh Anki profile" do
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
      it "instantiates a deck belonging to the collection argument" do
        expect(deck_from_existing.collection).to eq collection_argument
      end
      it "instantiates a deck with the id from the deck JSON" do
        expect(deck_from_existing.id).to eq 1
      end
      it "instantiates a deck with the last modified time from the deck JSON" do
        expect(deck_from_existing.last_modified_time).to eq 0
      end
      it "instantiates a Deck with the name Default" do
        expect(deck_from_existing.name).to eq "Default"
      end
      it "instantiates a Deck with the description from the deck JSON" do
        expect(deck_from_existing.description).to eq ""
      end
      it "instantiates a Deck with the deck options group id from the deck JSON" do
        expect(deck_from_existing.deck_options_group_id).to eq 1
      end
    end
  end
end
