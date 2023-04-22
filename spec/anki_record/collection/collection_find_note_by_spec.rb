# frozen_string_literal: true

require "./spec/anki_record/support/collection_spec_helpers"

RSpec.describe AnkiRecord::Collection, "#find_note_by" do
  include_context "collection shared helpers"

  context "when passed an id argument where the collection does not have a note with that id" do
    it "returns nil" do
      expect(collection.find_note_by(id: "1234")).to be_nil
    end
  end

  context "when passed an id argument where the collection does have a note with that id" do
    # rubocop:disable RSpec/InstanceVariable
    let(:collection_with_note) do
      basic_note_type = collection.find_note_type_by name: "Basic"
      default_deck = collection.find_deck_by name: "Default"
      @note = AnkiRecord::Note.new(deck: default_deck, note_type: basic_note_type)
      @note.save
      collection
    end

    it "returns a note object" do
      expect(collection_with_note.find_note_by(id: @note.id)).to be_a AnkiRecord::Note
    end

    it "returns a note object with id equal to the id argument" do
      expect(collection_with_note.find_note_by(id: @note.id).id).to eq @note.id
    end

    it "returns a note object with one card" do
      expect(collection_with_note.find_note_by(id: @note.id).cards.count).to eq 1
    end

    it "returns a note object with one card equal to the id of the note's corresponding card record" do
      expect(collection_with_note.find_note_by(id: @note.id).cards.first.id).to eq @note.cards.first.id
    end
    # rubocop:enable RSpec/InstanceVariable
  end
end
