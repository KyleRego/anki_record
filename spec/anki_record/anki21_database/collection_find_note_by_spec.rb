# frozen_string_literal: true

RSpec.describe AnkiRecord::Anki21Database, "#find_note_by" do
  let(:anki_package) { AnkiRecord::AnkiPackage.new(name: "test") }
  let(:anki21_database) { anki_package.anki21_database }
  let(:note) do
    collection = anki_package.collection
    default_deck = collection.find_deck_by(name: "Default")
    basic_note_type = collection.find_note_type_by(name: "Basic")
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

  it "returns the note with the given id" do
    found_note = anki21_database.find_note_by(id: note.id)
    expect(found_note).to be_a AnkiRecord::Note
    expect(found_note.id).to eq note.id
    expect(found_note.cards.count).to eq 1
    expect(found_note.cards.first.id).to eq card.id
  end
end