# frozen_string_literal: true

require "./spec/anki_record/support/collection_spec_helpers"

RSpec.describe AnkiRecord::Collection, "#find_deck_options_group_by" do
  include_context "collection shared helpers"

  context "when passed an id argument where the collection does not have a note type with that id" do
    it "returns nil" do
      expect(collection.find_deck_options_group_by(id: "1234")).to be_nil
    end
  end

  context "when passed an id argument where the collection has a deck with that id" do
    let(:default_deck_options_group_id) { collection.find_deck_by(name: "Default").deck_options_group.id }

    it "returns a note type object" do
      expect(collection.find_deck_options_group_by(id: default_deck_options_group_id)).to be_a AnkiRecord::DeckOptionsGroup
    end

    it "returns a note type object with name equal to the name argument" do
      expect(collection.find_deck_by(id: default_deck_options_group_id).id).to eq default_deck_options_group_id
    end
  end
end
