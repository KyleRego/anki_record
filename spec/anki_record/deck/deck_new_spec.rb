# frozen_string_literal: true

RSpec.describe AnkiRecord::Deck, "#new" do
  after { cleanup_test_files(directory: ".") }

  context "when passed collection and name arguments" do
    subject(:deck) { described_class.new collection: collection, name: "test deck" }

    let(:collection) { AnkiRecord::AnkiPackage.new(name: "decks_spec_package_1").collection }

    deck_integration_test_one = <<~DESC
      1. instantiates a new Deck object
      2. instantiates a deck with collection attribute which is the collection argument
      3. instantiates a deck which is added to the decks of the collection argument's decks attribute
      4. instantiates a deck with an empty string description
      5. instantiates a deck with an integer id attribute
      6. instantiates a deck with an integer last_modified_timestamp attribute
      7. instantiates a deck with deck_options_group returning a deck options group object
      8. instantiates a deck with deck_options_group returning a deck options group object with an id equal to 1
      9. does not save a deck to the collection.anki21 database
    DESC

    # rubocop:disable RSpec/ExampleLength
    it(deck_integration_test_one) do
      # 1
      expect(deck).to be_a described_class
      # 2
      expect(deck.collection).to eq collection
      # 3
      expect(deck.collection.decks).to include deck
      # 4
      expect(deck.description).to eq ""
      # 5
      expect(deck.id).to be_a Integer
      # 6
      expect(deck.id).to be_a Integer
      # 7
      expect(deck.deck_options_group).to be_a AnkiRecord::DeckOptionsGroup
      # 8
      expect(deck.deck_options_group.id).to eq 1
      # 9
      expect(collection.decks_json.keys).to_not include deck.id.to_s
    end
  end
  # rubocop:enable RSpec/ExampleLength

  context "when passed collection, name, and args arguments" do
    let(:collection) { AnkiRecord::AnkiPackage.new(name: "decks_spec_package").collection }

    it "throws an ArgumentError" do
      expect { described_class.new(collection: collection, name: "test", args: {}) }.to raise_error ArgumentError
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

  context "when passed collection and args arguments (and args is the Default deck hash)" do
    subject(:default_deck_from_existing) { described_class.new(collection: collection, args: default_deck_hash) }

    let(:collection) { AnkiRecord::AnkiPackage.new(name: "decks_spec_package_2").collection }

    deck_integration_test_two = <<~DESC
      1. instantiates a deck with collection attribute equal to the collection argument
      2. instantiates a deck which is added to the decks of the collection argument's decks attribute
      3. instantiates a deck with the id from the deck JSON
      4. instantiates a deck with the last modified time from the deck JSON
      5. instantiates a deck with the name Default
      6. instantiates a deck with the description from the deck JSON
      7. instantiates a deck with deck_options_group returning a deck options group object
      8. instantiates a deck with deck_options_group returning a deck options group object with id equal to id the value from the deck JSON (the conf)
      9. saves a deck to the collection.anki21 database
    DESC

    # rubocop:disable RSpec/ExampleLength
    it(deck_integration_test_two) do
      # 1
      expect(default_deck_from_existing.collection).to eq collection
      # 2
      expect(default_deck_from_existing.collection.decks).to include default_deck_from_existing
      # 3
      expect(default_deck_from_existing.id).to eq 1
      # 4
      expect(default_deck_from_existing.last_modified_timestamp).to eq 0
      #  5
      expect(default_deck_from_existing.name).to eq "Default"
      # 6
      expect(default_deck_from_existing.description).to eq ""
      # 7
      expect(default_deck_from_existing.deck_options_group).to be_a AnkiRecord::DeckOptionsGroup
      # 8
      expect(default_deck_from_existing.deck_options_group.id).to eq 1
      # 9
      expect(collection.decks_json.keys).to include default_deck_from_existing.id.to_s
    end
    # rubocop:enable RSpec/ExampleLength
  end
end
