# frozen_string_literal: true

RSpec.describe AnkiRecord::DeckOptionsGroup, "#new" do
  after { cleanup_test_files(directory: ".") }

  let(:collection_argument) do
    AnkiRecord::AnkiPackage.new(name: "package_to_setup_collection").collection
  end

  context "with no name or args arguments" do
    subject(:deck_options_group) { described_class.new(collection: collection_argument, name: name_argument) }

    let(:name_argument) { nil }

    it "throws an ArgumentError" do
      expect { deck_options_group }.to raise_error ArgumentError
    end
  end

  context "with collection and name arguments" do
    subject(:deck_options_group) { described_class.new(collection: collection_argument, name: name_argument) }

    let(:name_argument) { "Test deck options group" }

    it "instantiates a new deck options group" do
      expect(deck_options_group).to be_a described_class
    end

    it "instantiates a new deck options group with a collection attribute being the collection argument it was instantiated with" do
      expect(deck_options_group.collection).to eq collection_argument
    end

    it "instantiates a new deck options group object that is added to the collection arguments deck_options_groups attribute" do
      expect(deck_options_group.collection.deck_options_groups).to include deck_options_group
    end

    it "instantiates a new deck options group with an integer id" do
      expect(deck_options_group.id).to be_a Integer
    end

    it "instantiates a new deck options group with an integer last_modified_timestamp" do
      expect(deck_options_group.last_modified_timestamp).to be_a Integer
    end
  end

  context "with collection and an args which is the default deck options JSON object from a new Anki profile" do
    subject(:deck_options_group_from_existing) do
      described_class.new(collection: collection_argument, args: deck_options_group_hash)
    end

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

    it "instantiates a deck options group with collection attribute equal to the collection argument" do
      expect(deck_options_group_from_existing.collection).to eq collection_argument
    end

    it "instantiates a new deck options group object that is added to the collection arguments deck_options_groups attribute" do
      expect(deck_options_group_from_existing.collection.deck_options_groups).to include deck_options_group_from_existing
    end

    it "instantiates a deck options group with name from the JSON data" do
      expect(deck_options_group_from_existing.name).to eq "Default"
    end

    it "instantiates a deck options group with id from the JSON data" do
      expect(deck_options_group_from_existing.id).to eq 1
    end

    it "instantiates a deck options group with a last modified time from the JSON data" do
      expect(deck_options_group_from_existing.last_modified_timestamp).to eq 0
    end
  end
end
