# frozen_string_literal: true

require "./spec/anki_record/support/clean_slate_anki_package"
require "./spec/anki_record/support/deck_options_group_hash"

RSpec.describe AnkiRecord::DeckOptionsGroup, "#new" do
  include_context "when the anki package is a clean slate"

  it "throws an error when passed no name or args" do
    expect { described_class.new(collection:, name: nil) }.to raise_error ArgumentError
  end

  # rubocop:disable RSpec/ExampleLength
  it "instantiates a deck options group when passed a collection and name" do
    deck_options_group = described_class.new(collection:, name: "deck options group name")
    expect(deck_options_group).to be_a described_class
    expect(deck_options_group.collection).to eq collection
    expect(deck_options_group.collection.deck_options_groups).to include deck_options_group
    expect(deck_options_group.id).to be_a Integer
    expect(deck_options_group.last_modified_timestamp).to be_a Integer
  end
  # rubocop:enable RSpec/ExampleLength

  context "with collection and an args arguments (and args is the default deck options group)" do
    subject(:deck_options_group_from_hash) { described_class.new(collection:, args: default_deck_options_group_hash) }

    include_context "when the JSON of a deck options group from the col record is a Ruby hash"

    it "instantiates a deck options group from the raw data" do
      expect(deck_options_group_from_hash.collection).to eq collection
      expect(deck_options_group_from_hash.collection.deck_options_groups).to include deck_options_group_from_hash
      expect(deck_options_group_from_hash.name).to eq "Default"
      expect(deck_options_group_from_hash.id).to eq 1
      expect(deck_options_group_from_hash.last_modified_timestamp).to eq 0
    end
  end
end
