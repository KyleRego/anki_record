# frozen_string_literal: true

require "anki_record"

note_id = nil

AnkiRecord::AnkiPackage.new(name: "test_1") do |collection|
  crazy_deck = AnkiRecord::Deck.new collection: collection, name: "test_1_deck"

  crazy_note_type = AnkiRecord::NoteType.new collection: collection, name: "test 1 note type"
  AnkiRecord::NoteField.new note_type: crazy_note_type, name: "crazy front"
  AnkiRecord::NoteField.new note_type: crazy_note_type, name: "crazy back"
  crazy_card_template = AnkiRecord::CardTemplate.new note_type: crazy_note_type, name: "test 1 card 1"
  crazy_card_template.question_format = "{{crazy front}}"
  crazy_card_template.answer_format = "{{crazy back}}"
  second_crazy_card_template = AnkiRecord::CardTemplate.new note_type: crazy_note_type, name: "test 1 card 2"
  second_crazy_card_template.question_format = "{{crazy back}}"
  second_crazy_card_template.answer_format = "{{crazy front}}"

  css = <<~CSS
    .card {
      font-size: 16px;
      font-style: Verdana;
      background: transparent;
      text-align: center;
    }
  CSS

  crazy_note_type.css = css
  crazy_note_type.save

  note = AnkiRecord::Note.new note_type: crazy_note_type, deck: crazy_deck
  note.crazy_front = "Hello from test 1"
  note.crazy_back = "World"
  note.save

  note_id = note.id
end

AnkiRecord::AnkiPackage.open(path: "./test_1.apkg") do |collection|
  note = collection.find_note_by id: note_id
  note.crazy_back = "Ruby"
  note.save
end
