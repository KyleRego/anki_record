# frozen_string_literal: true

RSpec.describe AnkiRecord::DeckOptionsGroup do
  subject(:deck_options_group) { AnkiRecord::DeckOptionsGroup.new(collection: collection_argument, name: name_argument) }
  let(:name_argument) { "Test deck options group" }

  after { cleanup_test_files(directory: ".") }

  let(:collection_argument) do
    anki_database = AnkiRecord::AnkiPackage.new(name: "package_to_setup_collection")
    AnkiRecord::Collection.new(anki_database: anki_database)
  end

  describe "::new" do
    context "without a name argument" do
      let(:name_argument) { nil }
      it "raises an ArgumentError" do
        expect { deck_options_group }.to raise_error ArgumentError
      end
    end
    context "with a name argument" do
      it "instantiates a new deck options group" do
        expect(deck_options_group.instance_of?(AnkiRecord::DeckOptionsGroup)).to eq true
      end
    end
  end

  describe "::from_existing" do
    subject(:deck_options_group_from_existing) do
      AnkiRecord::DeckOptionsGroup.new(collection: collection_argument, args: deck_options_group_hash)
    end
    context "when the deck options group hash is from the default deck options JSON object from a new Anki profile" do
      let(:deck_options_group_hash) do
        { "id" => 1,
          "mod" => 0,
          "name" => "Default",
          "usn" => 0,
          "maxTaken" => 60,
          "autoplay" => true,
          "timer" => 0,
          "replayq" => true,
          "new" => { "bury" => false, "delays" => [1.0, 10.0], "initialFactor" => 2500, "ints" => [1, 4, 0], "order" => 1, "perDay" => 20 },
          "rev" => { "bury" => false, "ease4" => 1.3, "ivlFct" => 1.0, "maxIvl" => 36_500, "perDay" => 200, "hardFactor" => 1.2 },
          "lapse" => { "delays" => [10.0], "leechAction" => 1, "leechFails" => 8, "minInt" => 1, "mult" => 0.0 },
          "dyn" => false,
          "newMix" => 0,
          "newPerDayMinimum" => 0,
          "interdayLearningMix" => 0,
          "reviewOrder" => 0,
          "newSortOrder" => 0,
          "newGatherPriority" => 0,
          "buryInterdayLearning" => false }
      end
      it "instantiates a deck options group belonging to the collection" do
        expect(deck_options_group_from_existing.collection).to eq collection_argument
      end
      it "instantiates a deck options group with an id from the JSON data" do
        expect(deck_options_group_from_existing.id).to eq 1
      end
      it "instantiates a deck options group with an last modified time from the JSON data" do
        expect(deck_options_group_from_existing.last_modified_time).to eq 0
      end
      # TODO: - specs for every attribute of DeckOptionsGroup
    end
  end
end
