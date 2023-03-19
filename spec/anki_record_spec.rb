# frozen_string_literal: true

RSpec.describe AnkiRecord do
  before(:all) { cleanup_test_files directory: "." }

  it "should create two Anki packages that import into Anki correctly (sets up a manual feature test)" do
    note_id = nil

    AnkiRecord::AnkiPackage.new(name: "end-to-end-test-package") do |collection|
      crazy_deck = AnkiRecord::Deck.new collection: collection, name: "end-to-end-test-deck"

      crazy_note_type = AnkiRecord::NoteType.new collection: collection, name: "crazy note type"
      AnkiRecord::NoteField.new note_type: crazy_note_type, name: "crazy front"
      AnkiRecord::NoteField.new note_type: crazy_note_type, name: "crazy back"
      crazy_card_template = AnkiRecord::CardTemplate.new note_type: crazy_note_type, name: "crazy card 1"
      crazy_card_template.question_format = "{{crazy front}}"
      crazy_card_template.answer_format = "{{crazy back}}"
      second_crazy_card_template = AnkiRecord::CardTemplate.new note_type: crazy_note_type, name: "crazy card 2"
      second_crazy_card_template.question_format = "{{crazy back}}"
      second_crazy_card_template.answer_format = "{{crazy front}}"
      crazy_note_type.save

      note = AnkiRecord::Note.new note_type: crazy_note_type, deck: crazy_deck
      note.crazy_front = "Hello"
      note.crazy_back = "World"
      note.save

      note_id = note.id
    end

    AnkiRecord::AnkiPackage.open(path: "./end-to-end-test-package.apkg") do |collection|
      note = collection.find_note_by id: note_id
      note.crazy_back = "Ruby"
      note.save
    end
  end
end
