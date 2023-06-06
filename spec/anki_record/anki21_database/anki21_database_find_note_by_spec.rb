# frozen_string_literal: true

require "./spec/anki_record/support/clean_slate_anki_package"

RSpec.describe AnkiRecord::Anki21Database, "#find_note_by" do
  include_context "when the anki package is a clean slate"

  let(:note) do
    default_deck = anki21_database.find_deck_by(name: "Default")
    basic_note_type = anki21_database.find_note_type_by(name: "Basic")
    note = AnkiRecord::Note.new(deck: default_deck, note_type: basic_note_type)
    note.save
    note
  end
  let(:card) do
    note.cards.first
  end

  it "returns nil when there is no note with the given id" do
    expect(anki21_database.find_note_by(id: "1234")).to be_nil
  end

  it "returns the note with the given id when it is passed the id as an integer" do
    found_note = anki21_database.find_note_by(id: note.id)
    expect(found_note).to be_a AnkiRecord::Note
    expect(found_note.id).to eq note.id
    expect(found_note.cards.count).to eq 1
    expect(found_note.cards.first.id).to eq card.id
  end

  # rubocop:disable RSpec/ExampleLength
  it "returns the note with the given id when it is passed the id as a string" do
    note_id = note.id.to_s
    found_note = anki21_database.find_note_by(id: note_id)
    expect(found_note).to be_a AnkiRecord::Note
    expect(found_note.id).to eq note.id
    expect(found_note.cards.count).to eq 1
    expect(found_note.cards.first.id).to eq card.id
  end
  # rubocop:enable RSpec/ExampleLength
end
