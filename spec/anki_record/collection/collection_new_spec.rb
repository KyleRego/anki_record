# frozen_string_literal: true

require "./spec/anki_record/support/collection_spec_helpers"

RSpec.describe AnkiRecord::Collection, "#new" do
  include_context "collection shared helpers"

  collection_new_integration_test = <<-DESC
    1. instantiates a new Collection object
    2. instantiates a new Collection object with anki_package attribute which is the AnkiPackage object argument
    3. instantiates a new Collection object with an id of 1
    4. instantiates a new Collection object with the created_at_timestamp attribute having an integer value
    5. instantiates a new Collection object with a last_modified_timestamp attribute having the value 0
    6. instantiates a new Collection object with 5 note types
    7. instantiates a new Collection object with the 5 default note types
    8. instantiates a new Collection object with note_types that are all instances of NoteType
    9. instantiates a new Collection object with 1 deck
    10. instantiates a new Collection object with a deck called 'Default'
    11. instantiates a new Collection object with decks that are all instances of Deck
    12. instantiates a new Collection object with 1 deck options group
    13. instantiates a new Collection object with a deck options group called 'Default'
    14. instantiates a new Collection object with deck_options_groups that are all instances of DeckOptionsGroup
  DESC

  # rubocop:disable RSpec/ExampleLength
  it(collection_new_integration_test) do
    # 1
    expect(collection).to be_a described_class
    # 2
    expect(collection.anki_package).to eq anki_package
    # 3
    expect(collection.id).to eq 1
    # 4
    expect(collection.created_at_timestamp).to be_a Integer
    # 5
    expect(collection.last_modified_timestamp).to eq 0
    # 6
    expect(collection.note_types.count).to eq 5
    # 7
    default_note_type_names_array = ["Basic", "Basic (and reversed card)", "Basic (optional reversed card)", "Basic (type in the answer)", "Cloze"]
    expect(collection.note_types.map(&:name).sort).to eq default_note_type_names_array
    # 8
    collection.note_types.all? { |note_type| expect(note_type).to be_a AnkiRecord::NoteType }
    # 9
    expect(collection.decks.count).to eq 1
    # 10
    expect(collection.decks.first.name).to eq "Default"
    # 11
    collection.decks.all? { |deck| expect(deck).to be_a AnkiRecord::Deck }
    # 12
    expect(collection.deck_options_groups.count).to eq 1
    # 13
    expect(collection.deck_options_groups.first.name).to eq "Default"
    # 14
    collection.deck_options_groups.all? { |deck_opts| expect(deck_opts).to be_a AnkiRecord::DeckOptionsGroup }
  end
  # rubocop:enable RSpec/ExampleLength
end
