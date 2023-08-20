# frozen_string_literal: true

require_relative "../support/clean_slate_anki_package"

RSpec.describe AnkiRecord::Note, "#sort_field_value" do
  subject(:sort_field_value) do
    note.sort_field_value
  end

  include_context "when the anki package is a clean slate"

  context "when the note is a saved default Basic Note" do
    let(:front) { "This is the sort field by default" }
    let(:note) do
      default_deck = anki21_database.find_deck_by(name: "Default")
      basic_note_type = anki21_database.find_note_type_by(name: "Basic")
      note = described_class.new(deck: default_deck, note_type: basic_note_type)
      note.front = front
      note.back = "Hello world"
      note.save
      note
    end

    it "returns the front's value because the front is the sort field for the Basic note type" do
      expect(sort_field_value).to eq front
    end
  end
end
