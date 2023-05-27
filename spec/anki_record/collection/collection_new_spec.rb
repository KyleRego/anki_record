# frozen_string_literal: true

require "./spec/anki_record/support/collection_spec_helpers"

RSpec.describe AnkiRecord::Collection, "#new" do
  include_context "collection shared helpers"

  # rubocop:disable RSpec/ExampleLength
  it "instantiates a collection with defaults: 1 deck, 1 deck options group, and 5 note types" do
    expect(collection).to be_a described_class
    expect(collection.anki21_database).to be_a(AnkiRecord::Anki21Database)
    expect(collection.id).to eq 1
    expect(collection.created_at_timestamp).to be_a Integer
    expect(collection.last_modified_timestamp).to eq 0
    expect(collection.note_types.count).to eq 5
    default_note_type_names_array = ["Basic", "Basic (and reversed card)", "Basic (optional reversed card)", "Basic (type in the answer)", "Cloze"]
    expect(collection.note_types.map(&:name).sort).to eq default_note_type_names_array
    collection.note_types.all? { |note_type| expect(note_type).to be_a AnkiRecord::NoteType }
    expect(collection.decks.count).to eq 1
    expect(collection.decks.first.name).to eq "Default"
    collection.decks.all? { |deck| expect(deck).to be_a AnkiRecord::Deck }
    expect(collection.deck_options_groups.count).to eq 1
    expect(collection.deck_options_groups.first.name).to eq "Default"
    collection.deck_options_groups.all? { |deck_opts| expect(deck_opts).to be_a AnkiRecord::DeckOptionsGroup }
  end
  # rubocop:enable RSpec/ExampleLength
end
