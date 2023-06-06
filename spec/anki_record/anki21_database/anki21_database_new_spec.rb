# frozen_string_literal: true

require "./spec/anki_record/support/clean_slate_anki_package"

RSpec.describe AnkiRecord::Anki21Database, "#new" do
  include_context "when the anki package is a clean slate"

  # rubocop:disable RSpec/ExampleLength
  it "instantiates an Anki21Database with defaults: 1 deck, 1 deck options group, and 5 note types" do
    expect(anki21_database).to be_a described_class
    expect(anki21_database.collection).to be_a(AnkiRecord::Collection)
    expect(anki21_database.note_types.count).to eq 5
    default_note_type_names_array = ["Basic", "Basic (and reversed card)", "Basic (optional reversed card)", "Basic (type in the answer)", "Cloze"]
    expect(anki21_database.note_types.map(&:name).sort).to eq default_note_type_names_array
    anki21_database.note_types.all? { |note_type| expect(note_type).to be_a AnkiRecord::NoteType }
    expect(anki21_database.decks.count).to eq 1
    expect(anki21_database.decks.first.name).to eq "Default"
    anki21_database.decks.all? { |deck| expect(deck).to be_a AnkiRecord::Deck }
    expect(anki21_database.deck_options_groups.count).to eq 1
    expect(anki21_database.deck_options_groups.first.name).to eq "Default"
    anki21_database.deck_options_groups.all? { |deck_opts| expect(deck_opts).to be_a AnkiRecord::DeckOptionsGroup }
  end
  # rubocop:enable RSpec/ExampleLength
end
