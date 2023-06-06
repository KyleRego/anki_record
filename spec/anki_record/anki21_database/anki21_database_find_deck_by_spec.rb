# frozen_string_literal: true

require "./spec/anki_record/support/clean_slate_anki_package"

RSpec.describe AnkiRecord::Anki21Database, "#find_deck_by" do
  include_context "when the anki package is a clean slate"

  context "when passed both name and id arguments" do
    it "throws an ArgumentError" do
      expect { anki21_database.find_deck_by(name: "name", id: "id") }.to raise_error ArgumentError
    end
  end

  context "when passed neither a name nor an id argument" do
    it "throws an ArgumentError" do
      expect { anki21_database.find_deck_by }.to raise_error ArgumentError
    end
  end

  context "when passed a name argument where the Anki database does not have a deck with that name" do
    it "returns nil" do
      expect(anki21_database.find_deck_by(name: "no-deck-with-this-name")).to be_nil
    end
  end

  context "when passed a name argument where the Anki database has a deck with that name" do
    it "returns a deck object" do
      expect(anki21_database.find_deck_by(name: "Default")).to be_a AnkiRecord::Deck
    end

    it "returns a deck object with name equal to the name argument" do
      expect(anki21_database.find_deck_by(name: "Default").name).to eq "Default"
    end
  end

  context "when passed an id argument where the Anki database does not have a note type with that id" do
    it "returns nil" do
      expect(anki21_database.find_deck_by(id: "1234")).to be_nil
    end
  end

  context "when passed an id argument where the Anki database has a deck with that id" do
    let(:default_deck_id) { anki21_database.find_deck_by(name: "Default").id }

    it "returns a note type object" do
      expect(anki21_database.find_deck_by(id: default_deck_id)).to be_a AnkiRecord::Deck
    end

    it "returns a note type object with name equal to the name argument" do
      expect(anki21_database.find_deck_by(id: default_deck_id).id).to eq default_deck_id
    end
  end
end
